class TimeoutManager
  attr_reader :timeoutrole, :timeoutmembers

  def initialize(bot, config)
    Thread.new {
      sleep(5) # Async loading of the bot
      @timeoutrole = bot.server(config[:server_id].to_i).roles.find { |role| role.id.to_i == config[:timeout_role_id].to_i }
      @timeoutmembers = timeoutrole.members
      sleep(3) # Let it think a bit
      autoupdate()
    }
  end

  def add_user(user)
    return unless user.is_a?(Discordrb::Member)
    (@timeoutmembers << user; user.add_role(@timeoutrole.id.to_i)) unless (@timeoutmembers.map { |user| user.id }).include?(user.id)
  end

  def autoupdate()
    Thread.new {
      loop {
        @timeoutmembers.each { |member|
          (@timeoutmembers.delete(member); member.remove_role(@timeoutrole.id.to_i)) unless member.timeout?
        }
        sleep(300)
      }
    }
  end

  def remove_user(user)
    return unless user.is_a?(Discordrb::Member)
    (@timeoutmembers.delete(user); user.remove_role(@timeoutrole.id.to_i))
  end
end
