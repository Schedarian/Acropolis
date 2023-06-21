package schematic.mindustry.api;

import com.google.gson.JsonObject;
import fi.iki.elonen.NanoHTTPD;
import schematic.mindustry.api.mindustry.ContentHandler;
import schematic.mindustry.api.mindustry.MindustryMap;
import schematic.mindustry.api.mindustry.MindustrySchematic;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;

import static schematic.mindustry.api.Vars.gson;

public class Server extends NanoHTTPD {
    public Server(int port) {
        super(port);
    }

    private static String processSchematic(String base64Data) {
        var temp = ContentHandler.parseSchematic(base64Data);
        var requirements = ContentHandler.getRequirements(temp);
        var schematic = new MindustrySchematic(
                temp.name(),
                temp.description(),
                requirements.substring(0, requirements.length() - 2),
                temp.width + "x" + temp.height + ", " + temp.tiles.size + " blocks",
                Base64.getEncoder().withoutPadding().encodeToString(ContentHandler.parseSchematicImage(temp))
        );

        return gson.toJson(schematic);
    }

    private static String processMap(String base64Data) throws IOException {
        var temp = ContentHandler.parseMap(new ByteArrayInputStream(Base64.getDecoder().decode(base64Data)));
        var map = new MindustryMap(
                temp.name(),
                temp.description(),
                temp.width + "x" + temp.height,
                Base64.getEncoder().withoutPadding().encodeToString(ContentHandler.parseMapImage(temp))
        );

        return gson.toJson(map);
    }

    @Override
    public Response serve(IHTTPSession session) {
        if (session.getMethod() == Method.POST) {
            try {
                Map<String, String> jsonMap = new HashMap<>();
                session.parseBody(jsonMap);

                String json = jsonMap.get("postData");
                JsonObject jsonObject = gson.fromJson(json, JsonObject.class);

                String type = jsonObject.get("type").getAsString();
                String data = jsonObject.get("data").getAsString();

                String result;

                switch (type) {
                    case "schematic" -> result = processSchematic(data);
                    case "map" -> result = processMap(data);
                    default -> {
                        return newFixedLengthResponse(
                                Response.Status.BAD_REQUEST,
                                NanoHTTPD.MIME_PLAINTEXT,
                                "Invalid type."
                        );
                    }
                }

                return newFixedLengthResponse(
                        Response.Status.OK,
                        NanoHTTPD.MIME_PLAINTEXT,
                        result
                );
            } catch (NullPointerException exception) {
                return newFixedLengthResponse(
                        Response.Status.BAD_REQUEST,
                        NanoHTTPD.MIME_PLAINTEXT,
                        "Type or data not transferred."
                );
            } catch (Exception exception) {
                return newFixedLengthResponse(
                        Response.Status.INTERNAL_ERROR,
                        NanoHTTPD.MIME_PLAINTEXT,
                        "An exception occurred: " + exception.getMessage()
                );
            }
        } else {
            return newFixedLengthResponse(
                    Response.Status.METHOD_NOT_ALLOWED,
                    NanoHTTPD.MIME_PLAINTEXT,
                    "Unsupported method."
            );
        }
    }
}
