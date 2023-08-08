require "yaml"
require "discordrb"
require "bundler/setup"

# Load all files from the src directory
Dir["./src/*.rb"].each { |file| require file }

config = YAML.load(File.read("config.yaml"), symbolize_names: true)

bot = Discordrb::Bot.new(token: config[:bot_token], intents: :all)
bot.init_cache
bot.ready {
  bot.idle
  loop {
    bot.playing = "ping for help"
    sleep(3600 * 6)
  }
}

# To avoid passing a lot of args in functions
vars = {
  :bot => bot,
  :config => config,
  :utils => Utils,
  :database => Database.new,
  :logger => MessageLogger.new(config),
  :parser => Parser.new(config[:api_port]),
  :timeoutmanager => TimeoutManager.new(bot, config),
}

Thread.new {
  sleep(1) # Load stuff
  EventHandler.init_events(vars)
  CommandHandler.init_commands(vars)
}

#bot.get_application_commands(server_id: vars[:config][:server_id]).each { |cmd| bot.delete_application_command(cmd.id, server_id: vars[:config][:server_id]) }

bot.run
