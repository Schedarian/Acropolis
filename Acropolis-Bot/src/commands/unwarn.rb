require_relative "../commands.rb"
require_relative "../config.rb"
require_relative "../database.rb"

unwarn_register = proc { |bot, server|
  bot.register_application_command(:unwarn, "Убрать предупреждение пользователю", server_id: server) { |cmd|
    cmd.user(:user, "Выберите пользователя", required: true)
  }
}

CommandHandler.add_command(unwarn_register)

unwarn_handler = proc { |bot|
  bot.application_command(:unwarn) { |handler|
    if bot.member(handler.server_id, handler.user.id).permission?(Config::WARNINGS_PERMISSION_LEVEL.to_sym) == false
      handler.defer(ephemeral: true)
      handler.send_message(content: "У вас нет прав на использование данной команды")
    else
      handler.defer(ephemeral: false)
      warncount = Database.remove_warning(handler.options["user"].to_s)

      if warncount.zero?
        handler.send_message(content: "У пользователя нет предупреждений")
      else
        embed = Discordrb::Webhooks::Embed.new
        embed.color = Config::DEFAULT_EMBED_COLOR
        embed.description = "**Убрано предупреждение пользователя** <@#{handler.options["user"]}>"
        embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Осталось предупреждений: #{warncount - 1}")

        handler.send_message(embeds: [embed])
      end
    end
  }
}

CommandHandler.add_handler(unwarn_handler)
