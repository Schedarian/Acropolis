package schematic.mindustry.api;

import arc.util.Log;
import schematic.mindustry.api.util.ResourceUtils;

import java.io.IOException;

import static schematic.mindustry.api.Vars.*;

public class Main {

    public static void main(String[] args) {
        cache.delete();

        dataDirectory.mkdirs();
        cache.mkdirs();
        resources.mkdirs();
        sprites.mkdirs();

        ResourceUtils.init();

        int port = Integer.parseInt(System.getenv("ACROPOLIS_PORT"));
        Server server = new Server(port);

        try {
            server.start();
            Log.info("Server started on port @", port);

            while (true) {
                Thread.sleep(1000);
            }
        } catch (IOException exception) {
            Log.err("Failed to start the server: @", exception);
        } catch (InterruptedException e) {
            e.printStackTrace();
        } finally {
            server.stop();
        }
    }
}


