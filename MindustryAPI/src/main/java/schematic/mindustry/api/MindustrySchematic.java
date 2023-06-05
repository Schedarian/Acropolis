package schematic.mindustry.api;

public class MindustrySchematic {
    String name;
    String description;
    String resources;
    String size;
    String base64image;

    public MindustrySchematic(String n, String d, String r, String s, String b) {
        name = n;
        description = d;
        resources = r;
        size = s;
        base64image = b;
    }
}
