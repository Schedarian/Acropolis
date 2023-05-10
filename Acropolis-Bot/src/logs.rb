require_relative "config.rb"

module MessageLogger
  @@messages = []

  def self.add_message(data)
    @@messages.shift if @@messages.size >= 1000
    @@messages << data
  end

  def self.message_edited(data, message_id, bot)
    found = nil
    found ||= @@messages.find { |msg| msg[:id] == message_id }
    return if found.nil?

    @@messages[@@messages.index(found)] = data

    embed = Discordrb::Webhooks::Embed.new
    embed.author = Discordrb::Webhooks::EmbedAuthor.new(icon_url: data[:author].avatar_url, name: data[:author].username)
    embed.add_field(name: "Сообщение отредактировано", value: "<##{data[:channel]}> -> [Ссылка на сообщение](#{data[:link]})", inline: false)
    embed.add_field(name: "До", value: found[:content], inline: true)
    embed.add_field(name: "После", value: data[:content], inline: true)
    embed.image = Discordrb::Webhooks::EmbedImage.new(url: found[:attachment]) # Before editing
    embed.color = Config::DEFAULT_EMBED_COLOR

    bot.channel(Config::LOGS_CHANNEL_ID, Config::SERVER_ID).send_message("", false, embed)
  end

  def self.message_deleted(event_id, bot)
    found = nil
    found ||= @@messages.find { |msg| msg[:id] == event_id }
    return if found.nil?

    embed = Discordrb::Webhooks::Embed.new
    embed.author = Discordrb::Webhooks::EmbedAuthor.new(icon_url: found[:author].avatar_url, name: found[:author].username)
    embed.add_field(name: "Сообщение удалено", value: "<##{found[:channel]}>", inline: false)
    embed.add_field(name: "Содержимое", value: found[:content].empty? ? "[Это сообщение пустое или является вложением]" : found[:content], inline: false)
    embed.image = Discordrb::Webhooks::EmbedImage.new(url: found[:attachment])
    embed.color = Config::DEFAULT_EMBED_COLOR

    bot.channel(Config::LOGS_CHANNEL_ID, Config::SERVER_ID).send_message("", false, embed)
  end
end
