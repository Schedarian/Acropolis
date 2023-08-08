Command_Warnings = lambda { |vars|
  if vars[:config][:register_commands?]
    vars[:bot].register_application_command(:warnings, "Оставьте <user> пустым для просмотра своих предупреждений", server_id: vars[:config][:server_id]) { |cmd|
      cmd.user(:user, "Выберите пользователя", required: false)
    }
  end

  vars[:bot].application_command(:warnings) { |handler|
    if handler.options["user"].nil?
      handler.defer(ephemeral: true)
      warnings = vars[:database].get_warnings(handler.user.id)

      embed = Discordrb::Webhooks::Embed.new
      embed.color = vars[:config][:default_embed_color]

      if warnings[0].zero?
        handler.send_message(content: "У вас нет предупреждений")
      else
        embed.description = "**Ваши предупреждения**"

        day = lambda { |days|
          return "#{days} день" if days == 1 or days == 21
          return "#{days} дня" if days.between?(2, 4) or days.between?(22, 24)
          return "#{days} дней"
        }

        warnings[1].each_with_index { |warn, i|
          embed.add_field(name: "##{i + 1}", value: "Причина: #{warn[0]}\nВыдан: <@#{warn[1]}>\nДата: <t:#{warn[2]}>\n[Истекает через #{day.call(((Time.at(warn[2].to_i + 2592000) - Time.now) / 86400).ceil)}]", inline: true)
        }

        handler.send_message(embeds: [embed])
      end
    else
      if (vars[:bot].member(handler.server_id, handler.user.id).permission?(:ban_members) == false)
        handler.defer(ephemeral: true)
        handler.send_message(content: "У вас нет прав на использование данной команды")
      else
        handler.defer(ephemeral: false)
        warnings = vars[:database].get_warnings(handler.options["user"])

        embed = Discordrb::Webhooks::Embed.new
        embed.color = vars[:config][:default_embed_color]

        if warnings[0].zero?
          embed.description = "У пользователя <@#{handler.options["user"]}> нет предупреждений"
        else
          embed.description = "**Предупреждения пользователя** <@#{handler.options["user"]}>"

          warnings[1].each_with_index { |warn, i|
            embed.add_field(name: "##{i + 1}", value: "Причина: #{warn[0]}\nВыдан: <@#{warn[1]}>\nДата: <t:#{warn[2]}>\n[Истекает через #{((Time.at(warn[2].to_i + 2592000) - Time.now) / 86400).ceil} дней]", inline: true)
          }
        end

        handler.send_message(embeds: [embed])
      end
    end
  }
}
