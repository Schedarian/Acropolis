require_relative "config.rb"

module Starboard
  @@sbmessages = []

  def self.load_starboard(bot)
    sbchannel = bot.channel(Config::STARBOARD_CHANNEL_ID, Config::SERVER_ID)
    @@sbmessages = sbchannel.history(100).filter { |msg| !msg&.embeds&.first&.footer.nil? }
  end

  def self.add_message(message)
    @@sbmessages.shift if @@sbmessages.size >= 100
    @@sbmessages << message
  end

  def self.star_added(event, bot)
    return if event.message.content.size > 1024
    reactions = event.message.reactions.find { |r| r.name == "⭐" }
    return if reactions.count < Config::STARBOARD_STAR_COUNT

    found = @@sbmessages.find { |e| e.embeds.first.footer.text[4..-1] == event.message.id.to_s }

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

      begin
        found.edit("", new_embed)
      rescue Discordrb::Errors::NoPermission
        puts "Попытка отредактировать не своё сообщение, можно игнорировать"
      end
    else
      embed_value = event.message.content
      embed_value += "\n#{event.message.attachments&.first&.url}"

      msg = bot.channel(Config::STARBOARD_CHANNEL_ID, Config::SERVER_ID).send_embed { |embed|
        embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: event.message.author.name, icon_url: event.message.author.avatar_url)
        embed.description = "**#{reactions.count}** ⭐ **[К сообщению](#{event.message.link})**"
        embed.add_field(name: "Содержимое", value: embed_value, inline: false)
        embed.image = Discordrb::Webhooks::EmbedImage.new(url: event.message.attachments&.first&.url)
        embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "ID: #{event.message.id.to_s}")
        embed.color = Config::DEFAULT_EMBED_COLOR
      }

      self.add_message(msg)
    end
  end
end
