require_relative "../events.rb"
require_relative "../logs.rb"

message_edit_event = proc { |handler|
  handler.message_edit { |event|
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
        MessageLogger.message_edited(data, event.message.id, handler)
      end
    end
  }
}

EventHandler.add_handler(message_edit_event)
