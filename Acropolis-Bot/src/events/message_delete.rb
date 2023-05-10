require_relative "../events.rb"
require_relative "../logs.rb"

message_delete_event = proc { |handler|
  handler.message_delete { |event|
    unless event.channel.server.nil?
      MessageLogger.message_deleted(event.id, handler)
    end
  }
}

EventHandler.add_handler(message_delete_event)
