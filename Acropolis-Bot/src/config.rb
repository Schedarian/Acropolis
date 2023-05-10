require "yaml"

module Config
  CONFIG = YAML.load(File.read("config.yaml"))

  BOT_TOKEN = CONFIG["bot_token"]
  DEFAULT_EMBED_COLOR = CONFIG["default_embed_color"]
  START_TIME = Time.now.to_i
  SERVER_ID = CONFIG["server_id"]
  SCHEMATICS_CHANNEL_ID = CONFIG["schematics_channel_id"]
  MAPS_CHANNEL_ID = CONFIG["maps_channel_id"]
  LOGS_CHANNEL_ID = CONFIG["logs_channel_id"]
  STARBOARD_CHANNEL_ID = CONFIG["starboard_channel_id"]
  STARBOARD_STAR_COUNT = CONFIG["starboard_star_count"]
  WARNINGS_PERMISSION_LEVEL = CONFIG["warnings_permission_level"]
  MEMBER_COUNTER_CHANNEL_ID = CONFIG["member_counter_channel_id"]
end
