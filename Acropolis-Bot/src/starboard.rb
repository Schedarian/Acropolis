class Starboard
  def initialize(config)
    @messages = []
    @starboard_channel = config[:starboard_channel_id]
    @server = config[:server_id]
    @embed_color = config[:default_embed_color]
    @stars = config[:starboard_star_count]
  end

  def load_starboard(bot)
    channel = bot.channel(@starboardchannel, @server)
    @messages = channel.history(100).filter { |msg| !msg&.embeds&.first&.footer.nil? }
  end

  def add_message(message)
    @messages.shift if @messages.size >= 100
    @messages << message
  end

  def star_added(event)
    return if event.message.content.size > 1024
    reactions = event.message.reactions.find { |r| r.name == "⭐" }
    return if reactions.count < @stars

    found = @messages.find { |e| e.embeds.first.footer.text[4..-1] == event.message.id.to_s }

    unless found.nil?
      return if reactions.count <= found.embeds.first.description[0..20].tr("^0-9", "").to_i
      old_embed = found.embeds.first

      new_embed = Discordrb::Webhooks::Embed.new
      new_embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: old_embed.author.name, icon_url: old_embed.author.icon_url)
      new_embed.color = old_embed.color
      new_embed.description = "**#{reactions.count}** ⭐ **[К сообщению](#{event.message.link})**"
      new_embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: old_embed.footer.text)
      new_embed.image = Discordrb::Webhooks::EmbedImage.new(url: old_embed.image.url) unless old_embed.image.nil?
      new_embed.add_field(name: old_embed.fields.first.name, value: old_embed.fields.first.value, inline: false)

      return {
               :type => "edit",
               :message => found,
               :new_embed => embed,
             }
    end

    embed_value = event.message.content
    embed_value += "\n#{event.message.attachments&.first&.url}"
    embad_value = "[Текст сообщения пуст]" if embed_value.empty?

    embed = Discordrb::Webhooks::Embed.new

    embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: event.message.author.name, icon_url: event.message.author.avatar_url)
    embed.description = "**#{reactions.count}** ⭐ **[К сообщению](#{event.message.link})**"
    embed.add_field(name: "Содержимое", value: embed_value, inline: false)
    embed.image = Discordrb::Webhooks::EmbedImage.new(url: event.message.attachments&.first&.url)
    embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "ID: #{event.message.id.to_s}")
    embed.color = @embed_color

    return {
             :type => "new",
             :embed => embed,
           }
  end
end
