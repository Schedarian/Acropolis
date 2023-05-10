module EventHandler
  @@handlers = []

  def self.add_handler(handler)
    @@handlers << handler
  end

  def self.handle_events(bot)
    @@handlers.each { |handler|
      handler.call(bot)
    }
  end
end
