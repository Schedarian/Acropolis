package schematic.mindustry.api;

import arc.files.Fi;
import arc.struct.ObjectMap;
import com.google.gson.Gson;

import java.awt.*;
import java.awt.image.BufferedImage;

public class Vars {
    public static final Gson gson = new Gson();

    public static final Fi dataDirectory = Fi.get(".mindustry");
    public static final Fi cache = dataDirectory.child("cache");
    public static final Fi resources = dataDirectory.child("resources");
    public static final Fi sprites = dataDirectory.child("sprites");

    public static final ObjectMap<String, BufferedImage> regions = new ObjectMap<>();

    public static BufferedImage currentImage;
    public static Graphics2D currentGraphics;
}
