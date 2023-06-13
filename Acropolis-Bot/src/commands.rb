# Load all command files
Dir["./src/commands/*.rb"].each { |file| require file }

module CommandHandler
  Commands = [
    Command_Embed,
    Command_Map,
    Command_Purge,
    Command_Say,
    Command_Schematic,
    Command_Warn,
    Command_Warnings,
    Command_Unwarn,
  ]

  def self.init_commands(vars)
    Commands.each_with_index { |command, i|
      command.call(vars)
      (puts "Регистрация команд: #{i + 1}/#{Commands.size}"; sleep(20)) if vars[:config][:register_commands?]
    }

    if vars[:config][:register_commands?]
      vars[:config][:register_commands?] = false
      File.write("config.yaml", vars[:config].to_yaml)
      puts "Все команды зарегистрированы, параметр изменён на false"
    else
      puts "Команды загружены"
    end
  end
end
