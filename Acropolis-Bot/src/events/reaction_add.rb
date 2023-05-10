require_relative "../events.rb"

reaction_add_event = proc { |handler|
  handler.reaction_add { |event|
    unless event.server.nil?
      Starboard.star_added(event, handler) if event.emoji.name == "⭐"
    end
  }
}

EventHandler.add_handler(reaction_add_event)
