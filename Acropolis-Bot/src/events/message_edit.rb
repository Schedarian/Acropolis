Event_MessageEdit = proc { |vars|
  vars[:bot].message_edit { |event|
    unless event.server.nil?
      size = event.message&.content&.size.nil? ? 0 : event.message.content.size
      unless size > 1024
        data = {
          :id => event.message.id,
          :author => event.message.author,
          :content => event.message.content,
          :channel => event.message.channel.id,
          :link => event.message.link,
          :attachment => event.message.attachments.first&.url,
        }

        embed = vars[:logger].message_edited(event.message.id, data)
        vars[:bot].channel(vars[:config][:logs_channel_id], vars[:config][:server_id]).send_message("", false, embed) unless embed.nil?
      end
    end
  }
}
