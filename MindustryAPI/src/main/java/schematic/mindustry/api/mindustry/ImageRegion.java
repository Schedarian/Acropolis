package schematic.mindustry.api.mindustry;

import arc.graphics.g2d.TextureAtlas.AtlasRegion;
import arc.graphics.g2d.TextureAtlas.TextureAtlasData.Region;

import java.awt.image.BufferedImage;

import static java.awt.image.BufferedImage.TYPE_INT_ARGB;
import static schematic.mindustry.api.Vars.regions;

public class ImageRegion extends AtlasRegion {

    public ImageRegion(Region region, BufferedImage atlasPage) {
        super(region.page.texture, region.left, region.top, region.width, region.height);

        name = region.name;
        texture = region.page.texture;

        var image = new BufferedImage(region.width, region.height, TYPE_INT_ARGB);
        var graphics = image.createGraphics();

        graphics.drawImage(
                atlasPage,
                0,
                0,
                region.width,
                region.height,
                region.left,
                region.top,
                region.left + region.width,
                region.top + region.height,
                null
        );

        regions.put(name, image);
    }
}
