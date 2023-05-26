Command_Purge = lambda { |vars|
  if vars[:config][:register_commands?]
    vars[:bot].register_application_command(:purge, "Удалить сообщения (от 2 до 100 штук)", server_id: vars[:config][:server_id]) { |cmd|
      cmd.integer(:count, "Количество сообщений", required: true)
    }
  end

  vars[:bot].application_command(:purge) { |handler|
    handler.defer(ephemeral: true)
    count = handler.options["count"].to_i
    count = 2 if count < 2
    count = 100 if count > 100

    begin
      if vars[:bot].member(handler.server_id, handler.user.id).permission?(:manage_messages) == false
        handler.send_message(content: "У вас нет прав на использование данной команды")
      else
        vars[:bot].channel(handler.channel_id, handler.server_id).prune(count)
        vars[:bot].channel(handler.channel_id, handler.server_id).send_embed { |embed|
          embed.color = vars[:config][:default_embed_color]
          embed.title = "Удалено сообщений: #{count}"
          embed.description = "**Пользователем** <@#{handler.user.id}>"
        }
        handler.send_message(content: "Сообщения успешно удалены")
      end
    rescue Discordrb::Errors::NoPermission
      handler.send_message(content: "Бот не имеет разрешения удалять чужие сообщения")
    end
  }
}
