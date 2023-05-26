Event_MessageCreate = lambda { |vars|
  vars[:bot].message { |event|
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
        vars[:logger].add_message(data)
      end
    end
  }
}
