module Membercounter
  def self.start_counter(bot)
    Thread.new {
      begin
        loop {
          bot.channel(Config::MEMBER_COUNTER_CHANNEL_ID, Config::SERVER_ID).name = "Участников: #{bot.servers[Config::SERVER_ID].member_count}"
          sleep(600)
        }
      rescue Discordrb::Errors::NoPermission
        puts "Бот не может изменять канал со счётчиком пользователей"
      end
    }
  end
end
