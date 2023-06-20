package schematic.mindustry.api;

import fi.iki.elonen.NanoHTTPD;
import schematic.mindustry.api.mindustry.ContentHandler;
import schematic.mindustry.api.mindustry.MindustryMap;
import schematic.mindustry.api.mindustry.MindustrySchematic;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.util.Base64;

import static schematic.mindustry.api.Vars.gson;

public class Server extends NanoHTTPD {
    public Server(int port) {
        super(port);
    }

    private static String processSchematic(String base64Data) throws IOException {
        var argument = new String(Base64.getDecoder().decode(base64Data));
        var temp = ContentHandler.parseSchematic(argument);
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
        var argument = new String(Base64.getDecoder().decode(base64Data));
        var temp = ContentHandler.parseMap(new ByteArrayInputStream(argument.getBytes()));
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
        if (session.getMethod() == Method.GET) {
            try {
                String data = session.getParameters().get("data").get(0);
                String type = session.getParameters().get("type").get(0);

                if (data == null || type == null) {
                    return newFixedLengthResponse(
                            Response.Status.BAD_REQUEST,
                            NanoHTTPD.MIME_PLAINTEXT,
                            "Type or data not transferred."
                    );
                }

                String result;

                switch (type) {
                    case "schematic":
                        result = processSchematic(data);
                        break;
                    case "map":
                        result = processMap(data);
                        break;
                    default:
                        return newFixedLengthResponse(
                                Response.Status.BAD_REQUEST,
                                NanoHTTPD.MIME_PLAINTEXT,
                                "Invalid type."
                        );
                }

                return newFixedLengthResponse(
                        Response.Status.OK,
                        NanoHTTPD.MIME_PLAINTEXT,
                        result
                );
            } catch (Exception exception) {
                exception.printStackTrace();
                return newFixedLengthResponse(
                        Response.Status.BAD_REQUEST,
                        NanoHTTPD.MIME_PLAINTEXT,
                        "An exception occurred: " + exception.getMessage()
                );
            }
        } else {
            return newFixedLengthResponse(
                    Response.Status.BAD_REQUEST,
                    NanoHTTPD.MIME_PLAINTEXT,
                    "Unsupported method."
            );
        }
    }
}
