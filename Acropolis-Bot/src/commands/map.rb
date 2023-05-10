require_relative "../commands.rb"
require_relative "../config.rb"
require_relative "../utils.rb"

require "down"

map_register = proc { |bot, server|
  bot.register_application_command(:map, "Загрузить карту в канал для карт", server_id: server) { |cmd|
    cmd.attachment(:file, "Файл карты", required: true)
  }
}

CommandHandler.add_command(map_register)

map_handler = proc { |bot|
  bot.application_command(:map) { |handler|
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
        channel = bot.channel(Config::MAPS_CHANNEL_ID, Config::SERVER_ID)

        imgfile = Tempfile.new(["image", ".png"], "./")
        imgfile.write(Base64.decode64(json["base64image"]))

        channel.send_file(mapfile.open, caption: nil, tts: false, filename: "#{json["name"]}.msav", spoiler: nil)

        channel.send_embed("", nil, [imgfile.open], false, nil, nil, nil) { |embed|
          embed.color = Config::DEFAULT_EMBED_COLOR
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

CommandHandler.add_handler(map_handler)
