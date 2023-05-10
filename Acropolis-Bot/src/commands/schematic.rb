require_relative "../commands.rb"
require_relative "../config.rb"
require_relative "../utils.rb"

schematic_register = proc { |bot, server|
  bot.register_application_command(:schematic, "Загрузить схему в канал для схем", server_id: server) { |cmd|
    cmd.string(:base64, "Схема в формате кодировки base64", required: true)
  }
}

CommandHandler.add_command(schematic_register)

schematic_handler = proc { |bot|
  bot.application_command(:schematic) { |handler|
    handler.defer(ephemeral: true)

    begin
      base64string = handler.options["base64"]

      if Utils.valid_base64?(base64string) == false
        handler.send_message(content: "Произошла ошибка обработки схемы")
      else
        api_output = `java -jar MindustryAPI.jar schematic #{base64string}`

        if Utils.valid_json?(api_output) == false
          handler.send_message(content: "Произошла ошибка обработки схемы")
        else
          json = JSON.parse(api_output)
          channel = bot.channel(Config::SCHEMATICS_CHANNEL_ID, Config::SERVER_ID)

          imgfile = Tempfile.new(["image", ".png"], "./")
          imgfile.write(Base64.decode64(json["base64image"]))

          textfile = Tempfile.new(["msch", ".txt"], "./")
          textfile.puts(base64string)

          channel.send_file(textfile.open)

          channel.send_embed("", nil, [imgfile.open], false, nil, nil, nil) { |embed|
            embed.color = Config::DEFAULT_EMBED_COLOR
            embed.author = Discordrb::Webhooks::EmbedAuthor.new(icon_url: handler.user.avatar_url, name: handler.user.username)
            embed.title = json["name"]
            embed.description = json["description"].empty? ? "[Описание отсутствует]" : json["description"]
            embed.add_field(name: "Необходимые ресурсы", value: json["resources"])
            embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: json["size"])
            embed.image = Discordrb::Webhooks::EmbedImage.new(url: "attachment://#{File.basename(imgfile.path)}")
          }

          handler.send_message(content: "Схема загружена в канал")
          sleep(5) # Make sure image is uploaded

          textfile.close
          textfile.unlink
          imgfile.close
          imgfile.unlink
        end
      end
    rescue Discordrb::Errors::NoPermission
      handler.send_message(content: "Бот не имеет доступа к каналу для схем")
    end
  }
}

CommandHandler.add_handler(schematic_handler)
