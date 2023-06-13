Command_Say = lambda { |vars|
  if vars[:config][:register_commands?]
    vars[:bot].register_application_command(:say, "Сообщение от имени бота, только для модераторов/администраторов", server_id: vars[:config]["server_id"]) { |cmd|
      cmd.string(:text, "Текст сообщения", required: true)
    }
  end

  vars[:bot].application_command(:say) { |handler|
    handler.defer(ephemeral: true)

    if vars[:bot].member(handler.server_id, handler.user.id).permission?(vars[:config][:moderator_commands_allowed].to_sym) == false
      handler.send_message(content: "У вас нет прав на использование данной команды")
    else
      begin
        handler.channel.send_message(handler.options["text"])
        handler.send_message(content: "Сообщение успешно отправлено")
      rescue Discordrb::Errors::NoPermission
        handler.send_message(content: "Бот не имеет доступа к этому каналу")
      end
    end
  }
}
