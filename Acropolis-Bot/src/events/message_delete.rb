Event_MessageDelete = lambda { |vars|
  vars[:bot].message_delete { |event|
    unless event.channel.server.nil?
      embed = vars[:logger].message_deleted(event.id)
      vars[:bot].channel(vars[:config][:logs_channel_id], vars[:config][:server_id]).send_message("", false, embed) unless embed.nil?
    end
  }
}
