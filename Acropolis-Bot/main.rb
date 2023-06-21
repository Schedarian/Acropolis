require "yaml"
require "discordrb"
require "bundler/setup"

# Load all files from the src directory
Dir["./src/*.rb"].each { |file| require file }

config = YAML.load(File.read("config.yaml"), symbolize_names: true)
database = Database.new
logger = MessageLogger.new(config)
parser = Parser.new(config[:api_port])

bot = Discordrb::Bot.new(token: config[:bot_token], intents: :all)
bot.init_cache
bot.ready {
  bot.idle
  loop {
    bot.playing = "Mindustry 2"
    sleep(3600 * 6)
  }
}

# To avoid passing a lot of args in functions
vars = {
  :bot => bot,
  :config => config,
  :utils => Utils,
  :database => database,
  :logger => logger,
  :parser => parser,
}

Thread.new {
  sleep(1) # Load stuff
  EventHandler.init_events(vars)
  CommandHandler.init_commands(vars)
}

bot.run
