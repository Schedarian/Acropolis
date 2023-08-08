Event_ReactionAdd = lambda { |vars|
  vars[:bot].reaction_add { |event|
    unless event.server.nil?
      if event.emoji.name == "❌" && event.message.author.id == vars[:config][:bot_id].to_i
        if event.user.id.to_i == event.message.embeds.first.footer.text.to_s[/UserID: (\d+)/, 1].to_i
          event.message.delete
        end
      end
    end
  }
}
