Command_Embed = lambda { |vars|
  if vars[:config][:register_commands?]
    vars[:bot].register_application_command(:embed, "Создать вложение, только для модераторов/администраторов", server_id: vars[:config][:server_id]) { |cmd|
      cmd.string(:json, "Вложение в формате JSON, без указания цвета рамки вложения он будет стандартным", required: true)
    }
  end

  vars[:bot].application_command(:embed) { |handler|
    handler.defer(ephemeral: true)

    if vars[:bot].member(handler.server_id, handler.user.id).permission?(vars[:config][:moderator_commands_allowed].to_sym) == false
      handler.send_message(content: "У вас нет прав на использование данной команды")
    else
      begin
        json = JSON.parse(handler.options["json"])

        handler.channel.send_embed { |embed|
          embed.author = Discordrb::Webhooks::EmbedAuthor.new(json["author"]["name"], json["author"]["url"], json["author"]["icon_url"]) unless json["author"].nil?
          embed.title = json["title"] unless json["title"].nil?
          embed.color = json["color"].nil? ? vars[:config][:default_embed_color] : json["color"][1..-1].to_i(16)
          embed.description = json["description"]
          embed.url = json["url"] unless json["url"].nil?
          embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: json["thumbnail"]["url"]) unless json["thumbnail"].nil?
          embed.image = Discordrb::Webhooks::EmbedImage.new(url: json["image"]["url"]) unless json["image"].nil?
          embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: json["footer"]["text"], icon_url: json["footer"]["icon_url"]) unless json["footer"].nil?
          embed.timestamp = Time.at(json["timestamp"].to_i, in: "+00:00") unless json["timestamp"].nil?
          json["fields"].each { |field|
            embed.add_field(name: field["name"], value: field["value"], inline: field["inline"])
          } unless json["fields"].nil?
        }
        handler.send_message(content: "Вложение успешно создано")
      rescue Discordrb::Errors::InvalidFormBody, ArgumentError
        handler.send_message(content: "Не удалось создать вложение, возможно JSON строка содержит ошибки")
      rescue Discordrb::Errors::NoPermission
        handler.send_message(content: "Бот не имеет доступа к этому каналу")
      end
    end
  }
}
