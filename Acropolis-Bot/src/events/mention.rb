Event_Mention = lambda { |vars|
  allowed_commands = {
    :embed => :administrator,
    :map => :send_messages,
    :media => :ban_members,
    :purge => :manage_messages,
    :say => :administrator,
    :schematic => :send_messages,
    :unwarn => :ban_members,
    :warn => :ban_members,
    :warnings => :send_messages,
  }

  vars[:bot].mention { |event|
    unless event.server.nil?
      commands = vars[:bot].get_application_commands(server_id: event.server.id)
      description = ""
      commands.each { |cmd|
        description += "</#{cmd.name}:#{cmd.id}> - #{cmd.description}\n" if vars[:bot].member(event.server.id, event.user.id).permission?(allowed_commands[cmd.name.to_sym])
      }

      embed = Discordrb::Webhooks::Embed.new
      embed.color = vars[:config][:default_embed_color]
      embed.title = "Помощь | Список доступных команд"
      embed.add_field(name: "Нажмите на команду, чтобы воспользоваться ей", value: description, inline: false)
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Это временное сообщение, иcчезающее через 30 секунд")

      event.channel.send_temporary_message("", 30, false, embed, nil, nil, nil, nil)
    end
  }
}
