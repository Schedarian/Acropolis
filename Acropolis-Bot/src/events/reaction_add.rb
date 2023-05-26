Event_ReactionAdd = proc { |vars|
  vars[:bot].reaction_add { |event|
    unless event.server.nil?
      response = vars[:starboard].star_added(event) if event.emoji.name == "⭐"
      unless response.nil?
        begin
          if response[:type] == "edit"
            response[:message].edit("", response[:new_embed])
          else
            vars[:starboard].add_message(vars[:bot].send_message(vars[:config][:starboard_channel_id], "", false, response[:embed]))
          end
        rescue Discordrb::Errors::NoPermission
          puts "Попытка отредактировать не своё сообщение, можно игнорировать"
        end
      end
    end
  }
}
