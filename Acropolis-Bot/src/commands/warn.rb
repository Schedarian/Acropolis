require_relative "../commands.rb"
require_relative "../config.rb"
require_relative "../database.rb"

warn_register = proc { |bot, server|
  bot.register_application_command(:warn, "Выдать предупреждение пользователю", server_id: server) { |cmd|
    cmd.user(:user, "Выберите пользователя", required: true)
    cmd.string(:reason, "Введите причину предупреждения (до 256 символов)", required: true)
  }
}

CommandHandler.add_command(warn_register)

warn_handler = proc { |bot|
  bot.application_command(:warn) { |handler|
    if bot.member(handler.server_id, handler.user.id).permission?(Config::WARNINGS_PERMISSION_LEVEL.to_sym) == false
      handler.defer(ephemeral: true)
      handler.send_message(content: "У вас нет прав на использование данной команды")
    else
      if handler.options["reason"].length > 256
        handler.defer(ephemeral: true)
        handler.send_message(content: "Максимальная длина причины предупреждения - 256 символов")
      else
        handler.defer(ephemeral: false)

        warncount = Database.add_warning(handler.options["user"].to_s, handler.options["reason"], handler.user.id.to_s, Time.now.to_i)
        warncount += 1

        if warncount > 5
          handler.send_message(content: "**У пользователя максимальное количество предупреждений**")
        else
          embed = Discordrb::Webhooks::Embed.new
          embed.color = Config::DEFAULT_EMBED_COLOR
          embed.description = "**Пользователь <@#{handler.options["user"]}> предупреждён**\n`Это случай №#{warncount}`"
          embed.add_field(name: "Причина", value: handler.options["reason"], inline: false)

          handler.send_message(embeds: [embed])
        end
      end
    end
  }
}

CommandHandler.add_handler(warn_handler)
