package schematic.mindustry.api;

import schematic.mindustry.api.util.ResourceUtils;

import schematic.mindustry.api.mindustry.ContentHandler;

import java.util.Arrays;
import java.util.EnumSet;
import java.util.Base64;
import java.io.ByteArrayInputStream;

import static arc.util.Log.err;
import static schematic.mindustry.api.Vars.*;

import schematic.mindustry.api.MindustrySchematic;
import schematic.mindustry.api.MindustryMap;

public class Main
{

    public static void main(String[] args)
    {
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

        if (args[0].equals("schematic")) {

            try {
                var temp = ContentHandler.parseSchematic(args[1]);
                var requirements = ContentHandler.getRequirements(temp); 

                var schem = new MindustrySchematic(
                    temp.name(), 
                    temp.description(), 
                    requirements.substring(0, requirements.length() - 2),
                    temp.width + "x" + temp.height + ", " + temp.tiles.size + " blocks",
                    Base64.getEncoder().withoutPadding().encodeToString(ContentHandler.parseSchematicImage(temp))
                );

                String result = gson.toJson(schem);
                System.out.println(result);
            }
            catch(Exception e)
            {
                System.out.println("Schematic parsing error");
            }
        } else if (args[0].equals("map")) {

            try {
                // Here you feed the .msav file encoded in base64 format to get the data
                var temp = ContentHandler.parseMap(new ByteArrayInputStream(Base64.getDecoder().decode(args[1])));

                var map = new MindustryMap(
                    temp.name(),
                    temp.description(),
                    temp.width + "x" + temp.height,
                    Base64.getEncoder().withoutPadding().encodeToString(ContentHandler.parseMapImage(temp))
                );

                String result = gson.toJson(map);
                System.out.println(result);
            }
            catch(Exception e) 
            {
                System.out.println("Map parsing error");
            }
        } else {
            System.out.println("Invalid arguments");
        }
    }
}
