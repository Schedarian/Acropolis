require_relative "../commands.rb"
require_relative "../config.rb"
require_relative "../utils.rb"

purge_register = proc { |bot, server|
  bot.register_application_command(:purge, "Удалить сообщения (от 2 до 100 штук)", server_id: server) { |cmd|
    cmd.integer(:count, "Количество сообщений", required: true)
  }
}

CommandHandler.add_command(purge_register)

handle_purge = proc { |bot|
  bot.application_command(:purge) { |handler|
    handler.defer(ephemeral: true)
    count = handler.options["count"].to_i
    count = 2 if count < 2
    count = 100 if count > 100

    begin
      if bot.member(handler.server_id, handler.user.id).permission?(:manage_messages) == false
        handler.send_message(content: "У вас нет прав на использование данной команды")
      else
        bot.channel(handler.channel_id, handler.server_id).prune(count)
        bot.channel(handler.channel_id, handler.server_id).send_embed { |embed|
          embed.color = Config::DEFAULT_EMBED_COLOR
          embed.title = "Удалено сообщений: #{count}"
          embed.description = "**Пользователем** <@#{handler.user.id}>"
        }
      end
    rescue Discordrb::Errors::NoPermission
      handler.send_message(content: "Бот не имеет разрешения удалять чужие сообщения")
    end
  }
}

CommandHandler.add_handler(handle_purge)
