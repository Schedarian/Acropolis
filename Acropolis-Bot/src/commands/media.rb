Command_Media = lambda { |vars|
  if vars[:config][:register_commands?]
    vars[:bot].register_application_command(:media, "Ограничить возможности пользователя, повторное использование убирает роль. Только для модераторов", server_id: vars[:config][:server_id]) { |cmd|
      cmd.user(:user, "Выберите пользователя", required: true)
    }
  end

  vars[:bot].application_command(:media) { |handler|
    handler.defer(ephemeral: true)

    if vars[:bot].member(handler.server_id, handler.user.id).permission?(:ban_members) == false
      handler.send_message(content: "У вас нет прав на использование данной команды")
    else
      begin
        member = vars[:bot].member(vars[:config][:server_id], handler.options["user"].to_i)
        rolelist = member.roles.map { |role| role.id.to_i }
        rolelist.include?(vars[:config][:nomedia_role_id].to_i) ? member.remove_role(vars[:config][:nomedia_role_id]) : member.add_role(vars[:config][:nomedia_role_id])
        handler.send_message(content: "Роль пользователя успешно изменена")
        handler.channel.send_embed { |embed|
          embed.color = vars[:config][:default_embed_color]
          embed.description = "**Роль <@&#{vars[:config][:nomedia_role_id]}> успешно #{rolelist.include?(vars[:config][:nomedia_role_id].to_i) ? "убрана у пользователя" : "добавлена пользователю"} <@#{handler.options["user"]}>**"
        }
      rescue Discordrb::Errors::NoPermission
        handler.send_message(content: "Бот не имеет прав присваивать роли")
      end
    end
  }
}
