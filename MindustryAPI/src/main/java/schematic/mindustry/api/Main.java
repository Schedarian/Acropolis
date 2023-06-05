package schematic.mindustry.api;

import schematic.mindustry.api.mindustry.ContentHandler;
import schematic.mindustry.api.util.ResourceUtils;

import java.io.ByteArrayInputStream;
import java.util.Base64;

import static schematic.mindustry.api.Vars.*;

public class Main {

    public static void main(String[] args) {
        cache.delete();

        dataDirectory.mkdirs();
        cache.mkdirs();
        resources.mkdirs();
        sprites.mkdirs();

        ResourceUtils.init();

        if (args.length < 2) {
            System.out.println("Invalid arguments");
            return;
        }

        String command = args[0];
        String argument = args[1];

        switch (command) {
            case "schematic" -> processSchematic(argument);
            case "map" -> processMap(argument);
            default -> System.out.println("Invalid arguments");
        }
    }

    private static void processSchematic(String argument) {
        try {
            var temp = ContentHandler.parseSchematic(argument);
            var requirements = ContentHandler.getRequirements(temp);
            var schematic = new MindustrySchematic(
                    temp.name(),
                    temp.description(),
                    requirements.substring(0, requirements.length() - 2),
                    temp.width + "x" + temp.height + ", " + temp.tiles.size + " blocks",
                    Base64.getEncoder().withoutPadding().encodeToString(ContentHandler.parseSchematicImage(temp))
            );
            System.out.println(gson.toJson(schematic));
        } catch (Exception e) {
            System.out.println("Schematic parsing error: " + e.getMessage());
        }
    }

    private static void processMap(String argument) {
        try {
            var temp = ContentHandler.parseMap(new ByteArrayInputStream(Base64.getDecoder().decode(argument)));
            var map = new MindustryMap(
                    temp.name(),
                    temp.description(),
                    temp.width + "x" + temp.height,
                    Base64.getEncoder().withoutPadding().encodeToString(ContentHandler.parseMapImage(temp))
            );
            System.out.println(gson.toJson(map));
        } catch (Exception e) {
            System.out.println("Map parsing error: " + e.getMessage());
        }
    }
}


