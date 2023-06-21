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

        int port;
        String envPort = System.getenv("ACROPOLIS_PORT");

        if (envPort == null || envPort.isEmpty()) {
            if (args.length > 0) port = Integer.parseInt(args[0]);
            else throw new IllegalStateException("ACROPOLIS_PORT environment variable or command line argument not found.");
        } else port = Integer.parseInt(envPort);

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


