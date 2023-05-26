module Utils
  def self.valid_json?(json)
    JSON.parse(json) rescue false
  end

  def self.valid_base64?(value)
    value.is_a?(String) && Base64.strict_encode64(Base64.decode64(value)) == value
  end
end
