require "net/http"
require "json"

class ParsingError < StandardError
  def initialize
    super("Error: Failed to parse schematic/map")
  end
end

class Parser
  def initialize(port)
    @port = port
  end

  def send_request(type, base64string)
    uri = URI("http://localhost:#{@port}")
    params = { type: type, data: base64string }
    headers = { 'Content-Type': "application/json" }

    response = Net::HTTP.post(uri, params.to_json, headers)
    response.code.to_i == 200 ? (return response.body) : (raise ParsingError)
  end
end
