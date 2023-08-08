Command_Warn = lambda { |vars|
  if vars[:config][:register_commands?]
    vars[:bot].register_application_command(:warn, "Выдать предупреждение. Только для модераторов", server_id: vars[:config][:server_id]) { |cmd|
      cmd.user(:user, "Выберите пользователя", required: true)
      cmd.string(:reason, "Введите причину предупреждения (до 256 символов)", required: true)
    }
  end

  vars[:bot].application_command(:warn) { |handler|
    if vars[:bot].member(handler.server_id, handler.user.id).permission?(:ban_members) == false
      handler.defer(ephemeral: true)
      handler.send_message(content: "У вас нет прав на использование данной команды")
    else
      if handler.options["reason"].length > 256
        handler.defer(ephemeral: true)
        handler.send_message(content: "Максимальная длина причины предупреждения - 256 символов")
      else
        handler.defer(ephemeral: false)

        warncount = vars[:database].add_warning(handler.options["user"].to_s, handler.options["reason"], handler.user.id.to_s, Time.now.to_i)
        warncount += 1

        if warncount > 1
          moderator_channel = vars[:bot].channel(vars[:config][:moderator_channel_id], vars[:config][:server_id])
          moderator_channel.send_message("У пользователя <@#{handler.options["user"]}> уже **#{warncount}** предупреждени#{warncount == 5 ? "й" : "я"}!")
          begin
            vars[:bot].member(vars[:config][:server_id], handler.options["user"].to_i).timeout = (warncount == 2 ? Time.now + 3600 : Time.now + 86400)
            moderator_channel.send_message("Автоматически выдан тайм-аут на 1 #{warncount == 2 ? "час" : "день"}")
          rescue Discordrb::Errors::NoPermission
            moderator_channel.send_message("У бота нет прав на выдачу тайм-аута, выдано только предупреждение")
          end
        end

        if warncount > 5
          handler.send_message(content: "**У пользователя максимальное количество предупреждений**")
        else
          embed = Discordrb::Webhooks::Embed.new
          embed.color = vars[:config][:default_embed_color]
          embed.description = "**Пользователь <@#{handler.options["user"]}> предупреждён**"
          embed.add_field(name: "Причина", value: handler.options["reason"], inline: false)
          embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Предупреждение ##{warncount}")

          handler.send_message(embeds: [embed])
        end
      end
    end
  }
}
