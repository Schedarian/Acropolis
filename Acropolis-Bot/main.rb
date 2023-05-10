require "bundler/setup"
require "discordrb"

require_relative "src/config.rb"
require_relative "src/database.rb"
require_relative "src/logs.rb"
require_relative "src/starboard.rb"
require_relative "src/commands.rb"
require_relative "src/membercounter.rb"

require_relative "src/commands/schematic.rb"
require_relative "src/commands/map.rb"
require_relative "src/commands/purge.rb"
require_relative "src/commands/warn.rb"
require_relative "src/commands/unwarn.rb"
require_relative "src/commands/warnings.rb"

require_relative "src/events/message_create.rb"
require_relative "src/events/message_edit.rb"
require_relative "src/events/message_delete.rb"
require_relative "src/events/reaction_add.rb"

bot = Discordrb::Bot.new(token: Config::BOT_TOKEN, intents: :all)
bot.init_cache
bot.ready {
  bot.idle
  # bot.delete_application_command(bot.get_application_commands.first.id)
}

Thread.new {
  sleep(5) # Let the bot load a bit
  CommandHandler.register_commands(bot)
  CommandHandler.handle_commands(bot)
  EventHandler.handle_events(bot)
  Starboard.load_starboard(bot)
  Membercounter.start_counter(bot)
  Database.check_db
  puts "[Bot is ready]"
}

bot.run

# What about blocked VC with member count?
# Bot status is online time in hours
