class MessageLogger
  def initialize(config)
    @messages = []
    @embed_color = config[:default_embed_color]
  end

  def add_message(message)
    @messages.shift if @messages.size >= 1000
    @messages << message
  end

  def message_edited(message_id, new_data)
    found = nil
    found ||= @messages.find { |msg| msg[:id] == message_id }
    return if found.nil?

    @messages[@messages.index(found)] = new_data

    embed = Discordrb::Webhooks::Embed.new
    embed.author = Discordrb::Webhooks::EmbedAuthor.new(icon_url: new_data[:author].avatar_url, name: new_data[:author].username)
    embed.add_field(name: "Сообщение отредактировано", value: "<##{new_data[:channel]}> -> [Ссылка на сообщение](#{new_data[:link]})", inline: false)
    embed.add_field(name: "До", value: found[:content], inline: true)
    embed.add_field(name: "После", value: new_data[:content], inline: true)
    embed.image = Discordrb::Webhooks::EmbedImage.new(url: found[:attachment]) # Before editing
    embed.color = @embed_color

    return embed
  end

  def message_deleted(event_id)
    found = nil
    found ||= @messages.find { |msg| msg[:id] == event_id }
    return if found.nil?

    embed = Discordrb::Webhooks::Embed.new
    embed.author = Discordrb::Webhooks::EmbedAuthor.new(icon_url: found[:author].avatar_url, name: found[:author].username)
    embed.add_field(name: "Сообщение удалено", value: "<##{found[:channel]}>", inline: false)
    embed.add_field(name: "Содержимое", value: found[:content].empty? ? "[Это сообщение пустое или является вложением]" : found[:content], inline: false)
    embed.image = Discordrb::Webhooks::EmbedImage.new(url: found[:attachment])
    embed.color = @embed_color

    return embed
  end
end
