Command_Unwarn = lambda { |vars|
  if vars[:config][:register_commands?]
    vars[:bot].register_application_command(:unwarn, "Убрать предупреждение пользователю", server_id: vars[:config][:server_id]) { |cmd|
      cmd.user(:user, "Выберите пользователя", required: true)
    }
  end

  vars[:bot].application_command(:unwarn) { |handler|
    if vars[:bot].member(handler.server_id, handler.user.id).permission?(vars[:config][:warnings_permission_level].to_sym) == false
      handler.defer(ephemeral: true)
      handler.send_message(content: "У вас нет прав на использование данной команды")
    else
      handler.defer(ephemeral: false)
      warncount = vars[:database].remove_warning(handler.options["user"].to_s)

      if warncount.zero?
        handler.send_message(content: "У пользователя нет предупреждений")
      else
        embed = Discordrb::Webhooks::Embed.new
        embed.color = vars[:config][:default_embed_color]
        embed.description = "**Убрано предупреждение пользователя** <@#{handler.options["user"]}>"
        embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Осталось предупреждений: #{warncount - 1}")

        handler.send_message(embeds: [embed])
      end
    end
  }
}
