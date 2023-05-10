require_relative "config.rb"

module CommandHandler
  @@commands = []
  @@handlers = []

  def self.add_command(command)
    @@commands << command
  end

  def self.add_handler(handler)
    @@handlers << handler
  end

  def self.register_commands(bot)
    Thread.new {
      @@commands.each { |command|
        command.call(bot, Config::SERVER_ID)
        sleep(20) # Avoid rate limiting
      }
    }
  end

  def self.handle_commands(bot)
    @@handlers.each { |handler|
      handler.call(bot)
    }
  end
end
