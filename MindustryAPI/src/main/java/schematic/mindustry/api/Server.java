package schematic.mindustry.api;

import fi.iki.elonen.NanoHTTPD;
import schematic.mindustry.api.mindustry.ContentHandler;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.util.Base64;

import static schematic.mindustry.api.Vars.gson;

public class Server extends NanoHTTPD {
    public Server(int port) {
        super(port);
    }

    private static String processSchematic(String argument) throws IOException {
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

    private static String processMap(String argument) throws IOException {
        var temp = ContentHandler.parseMap(new ByteArrayInputStream(Base64.getDecoder().decode(argument)));
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
                            Response.Status.INTERNAL_ERROR,
                            NanoHTTPD.MIME_PLAINTEXT,
                            "Type or data not transferred."
                    );
                }

                String result;

                switch (type) {
                    case "schematic" -> result = processSchematic(data);
                    case "map" -> result = processMap(data);
                    default -> {
                        return newFixedLengthResponse(
                                Response.Status.INTERNAL_ERROR,
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
            } catch (IllegalArgumentException exception) {
                exception.printStackTrace();
                return newFixedLengthResponse(
                        Response.Status.INTERNAL_ERROR,
                        NanoHTTPD.MIME_PLAINTEXT,
                        "Illegal character in Base64 encoded data: " + exception
                );
            } catch (IOException exception) {
                exception.printStackTrace();
                return newFixedLengthResponse(
                        Response.Status.INTERNAL_ERROR,
                        NanoHTTPD.MIME_PLAINTEXT,
                        "Error occurred while processing the string."
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
