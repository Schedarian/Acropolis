Dir["./src/events/*.rb"].each { |file| require file }

module EventHandler
  Events = [
    Event_MessageCreate,
    Event_MessageEdit,
    Event_MessageDelete,
    Event_MemberUpdate,
    Event_MemberTyping,
  ]

  def self.init_events(vars)
    Events.each { |event|
      event.call(vars)
    }
    puts "События загружены"
  end
end
