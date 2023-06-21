Command_Schematic = lambda { |vars|
  if vars[:config][:register_commands?]
    vars[:bot].register_application_command(:schematic, "Загрузить схему в канал для схем", server_id: vars[:config][:server_id]) { |cmd|
      cmd.string(:base64, "Схема в формате кодировки base64", required: true)
    }
  end

  vars[:bot].application_command(:schematic) { |handler|
    handler.defer(ephemeral: true)

    begin
      base64string = handler.options["base64"]

      if vars[:utils].valid_base64?(base64string) == false
        handler.send_message(content: "Произошла ошибка обработки схемы")
      else
        api_output = vars[:parser].send_request("schematic", base64string)
        json = JSON.parse(api_output)

        channel = vars[:bot].channel(vars[:config][:schematics_channel_id], vars[:config][:server_id])

        imgfile = Tempfile.new(["image", ".png"], "./")
        imgfile.write(Base64.decode64(json["base64image"]))

        textfile = Tempfile.new(["msch", ".txt"], "./")
        textfile.puts(base64string)

        channel.send_file(textfile.open)

        channel.send_embed("", nil, [imgfile.open], false, nil, nil, nil) { |embed|
          embed.color = vars[:config][:default_embed_color]
          embed.author = Discordrb::Webhooks::EmbedAuthor.new(icon_url: handler.user.avatar_url, name: handler.user.username)
          embed.title = json["name"]
          embed.description = json["description"].empty? ? nil : json["description"]
          embed.add_field(name: "Необходимые ресурсы", value: json["resources"].gsub(/\b\w+(?:-\w+)*\b/) { |m| vars[:utils]::Translations[m] || m }, inline: false)
          embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: json["size"].gsub("blocks", "блоков"))
          embed.image = Discordrb::Webhooks::EmbedImage.new(url: "attachment://#{File.basename(imgfile.path)}")
        }

        handler.send_message(content: "Схема загружена в канал")
        sleep(5) # Make sure image is uploaded

        textfile.close
        textfile.unlink

        imgfile.close
        imgfile.unlink
      end
    rescue Discordrb::Errors::NoPermission
      handler.send_message(content: "Бот не имеет доступа к каналу для схем")
    end
  }
}
