import arc.util.Log;
import arc.util.Strings;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

public class HttpTest {
    public static void main(String[] args) {
        String url = "http://localhost:6567";
        String mapType = "map";
        String mapData = "BASE64_ENCODED_MAP_DATA";
        String schematicType = "schematic";
        String schematicData = "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";

        try {
            sendRequest(url, mapType, mapData);
            sendRequest(url, schematicType, schematicData);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private static void sendRequest(String url, String type, String data) throws IOException {
        URL serverUrl = new URL(url);
        HttpURLConnection connection = (HttpURLConnection) serverUrl.openConnection();
        connection.setRequestMethod("GET");
        connection.setRequestProperty("Content-Type", "application/json");
        connection.setDoOutput(true);

        String jsonRequest = Strings.format("{\"type\":\"@\",\"data\":\"@\"}", type, data);

        try (OutputStream outputStream = connection.getOutputStream()) {
            outputStream.write(jsonRequest.getBytes(StandardCharsets.UTF_8));
            outputStream.flush();
        }

        int responseCode = connection.getResponseCode();

        if (responseCode == HttpURLConnection.HTTP_OK) {
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(connection.getInputStream()))) {
                StringBuilder response = new StringBuilder();
                String line;
                while ((line = reader.readLine()) != null) {
                    response.append(line);
                }
                String jsonResponse = response.toString();
                Log.info("Type: " + type + ", JSON Response: " + jsonResponse);
            }
        } else {
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(connection.getErrorStream()))) {
                StringBuilder response = new StringBuilder();
                String line;
                while ((line = reader.readLine()) != null) {
                    response.append(line);
                }
                String jsonResponse = response.toString();
                Log.info("Type: " + type + ", Response: " + jsonResponse);
            }

            // Log.info("Type: " + type + ", Request failed: " + responseCode + " " + connection.getResponseMessage());
        }

        connection.disconnect();
    }
}
