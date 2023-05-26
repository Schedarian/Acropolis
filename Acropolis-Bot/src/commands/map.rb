require "down"

Command_Map = lambda { |vars|
  if vars[:config][:register_commands?]
    vars[:bot].register_application_command(:map, "Загрузить карту в канал для карт", server_id: vars[:config]["server_id"]) { |cmd|
      cmd.attachment(:file, "Файл карты", required: true)
    }
  end

  vars[:bot].application_command(:map) { |handler|
    handler.defer(ephemeral: true)

    begin
      mapfile = Down.download(handler.resolved.attachments[handler.options["file"].to_i].url)

      base64map = Base64.strict_encode64(mapfile.read)
      api_output = `java -jar MindustryAPI.jar map #{base64map}`

      if Utils.valid_json?(api_output) == false
        handler.send_message(content: "Произошла ошибка обработки карты")
        mapfile.close
        mapfile.unlink
      else
        json = JSON.parse(api_output)
        channel = vars[:bot].channel(vars[:config][:maps_channel_id], vars[:config][:server_id])

        imgfile = Tempfile.new(["image", ".png"], "./")
        imgfile.write(Base64.decode64(json["base64image"]))

        channel.send_file(mapfile.open, caption: nil, tts: false, filename: "#{json["name"]}.msav", spoiler: nil)

        channel.send_embed("", nil, [imgfile.open], false, nil, nil, nil) { |embed|
          embed.color = config["default_embed_color"]
          embed.author = Discordrb::Webhooks::EmbedAuthor.new(icon_url: handler.user.avatar_url, name: handler.user.username)
          embed.title = json["name"]
          embed.description = json["description"] == "unknown" ? "[Описание отсутствует]" : json["description"]
          embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: json["size"])
          embed.image = Discordrb::Webhooks::EmbedImage.new(url: "attachment://#{File.basename(imgfile.path)}")
        }

        sleep(5) # Make sure everything is uploaded
        handler.send_message(content: "Карта загружена в канал")

        mapfile.close
        mapfile.unlink
        imgfile.close
        imgfile.unlink
      end
    rescue Discordrb::Errors::NoPermission
      handler.send_message(content: "Бот не имеет доступа к каналу для карт")
    end
  }
}
