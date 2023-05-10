require_relative "../commands.rb"
require_relative "../config.rb"
require_relative "../database.rb"

warnings_register = proc { |bot, server|
  bot.register_application_command(:warnings, "Оставьте <user> пустым для просмотра своих предупреждений", server_id: server) { |cmd|
    cmd.user(:user, "Выберите пользователя", required: false)
  }
}

CommandHandler.add_command(warnings_register)

warnings_handler = proc { |bot|
  bot.application_command(:warnings) { |handler|
    if handler.options["user"].nil?
      handler.defer(ephemeral: true)
      warnings = Database.get_warnings(handler.user.id)

      embed = Discordrb::Webhooks::Embed.new
      embed.color = Config::DEFAULT_EMBED_COLOR

      if warnings[0].zero?
        handler.send_message(content: "У вас нет предупреждений")
      else
        embed.description = "Ваши предупреждения"

        i = 1
        warnings[1].each { |warn|
          embed.add_field(name: "Случай №#{i}", value: "Причина: #{warn[0]}\nВыдан: <@#{warn[1]}>\nДата: <t:#{warn[2]}>\n[Истекает через #{((Time.at(warn[2].to_i + 2592000) - Time.now) / 86400).ceil} дней]", inline: true)
          i += 1
        }

        handler.send_message(embeds: [embed])
      end
    else
      if (bot.member(handler.server_id, handler.user.id).permission?(Config::WARNINGS_PERMISSION_LEVEL.to_sym) == false)
        handler.defer(ephemeral: true)
        handler.send_message(content: "У вас нет прав на использование данной команды")
      else
        handler.defer(ephemeral: false)
        warnings = Database.get_warnings(handler.options["user"])

        embed = Discordrb::Webhooks::Embed.new
        embed.color = Config::DEFAULT_EMBED_COLOR

        if warnings[0].zero?
          embed.description = "У пользователя <@#{handler.options["user"]}> нет предупреждений"
        else
          embed.description = "Предупреждения пользователя <@#{handler.options["user"]}>"

          i = 1
          warnings[1].each { |warn|
            embed.add_field(name: "Случай №#{i}", value: "Причина: #{warn[0]}\nВыдан: <@#{warn[1]}>\nДата: <t:#{warn[2]}>\n[Истекает через #{((Time.at(warn[2].to_i + 2592000) - Time.now) / 86400).ceil} дней]", inline: true)
            i += 1
          }
        end

        handler.send_message(embeds: [embed])
      end
    end
  }
}

CommandHandler.add_handler(warnings_handler)
