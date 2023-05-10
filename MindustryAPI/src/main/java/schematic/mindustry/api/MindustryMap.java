package schematic.mindustry.api;

import static schematic.mindustry.api.Vars.*;

public class MindustryMap {

    String name;
    String description;
    String size;
    String base64image;

    public MindustryMap(String n, String d, String s, String b){
        name = n;
        description = d;
        size = s;
        base64image = b;
    }
    
}