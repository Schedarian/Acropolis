module Utils

  # This is bullshit and a subject to change if you are hosting the bot yourself. Keep that in mind.
  Emojis = {
    :copper => "<:copper:966955321358708796>",
    :lead => "<:lead:1115238931756236810>",
    :titanium => "<:titanium:966955321350307860>",
    :thorium => "<:thorium:966955320989585440>",
    :scrap => "<:scrap:1115238901402054666>",
    :metaglass => "<:metaglass:1115238848973258863>",
    :graphite => "<:graphite:1115238821617999973>",
    :silicon => "<:silicon:966955321367072790>",
    :plastanium => "<:plastanium:1115238790852788325>",
    :surgealloy => "<:surgealloy:966955321371295784>",
    :phasefabric => "<:phasefabric:1115238749622784122>",
    :beryllium => "<:beryllium:973167677830987816>",
    :tungsten => "<:tungsten:973167677910712320>",
    :oxide => "<:oxide:1115238715955093554>",
    :carbide => "<:carbide:973167678242062406>",
  }.freeze

  Translations = {
    "copper" => "#{Emojis[:copper]} Медь",
    "lead" => "#{Emojis[:lead]} Cвинец",
    "titanium" => "#{Emojis[:titanium]} Титан",
    "thorium" => "#{Emojis[:thorium]} Торий",
    "scrap" => "#{Emojis[:scrap]} Металлолом",
    "metaglass" => "#{Emojis[:metaglass]} Метастекло",
    "graphite" => "#{Emojis[:graphite]} Графит",
    "silicon" => "#{Emojis[:silicon]} Кремний",
    "plastanium" => "#{Emojis[:plastanium]} Пластан",
    "surge-alloy" => "#{Emojis[:surgealloy]} Кинетический сплав",
    "phase-fabric" => "#{Emojis[:phasefabric]} Фазовая ткань",
    "beryllium" => "#{Emojis[:beryllium]} Бериллий",
    "tungsten" => "#{Emojis[:tungsten]} Вольфрам",
    "oxide" => "#{Emojis[:oxide]} Оксид",
    "carbide" => "#{Emojis[:carbide]} Карбид",
  }.freeze

  def self.valid_json?(json)
    JSON.parse(json) rescue false
  end

  def self.valid_base64?(value)
    value.is_a?(String) && Base64.strict_encode64(Base64.decode64(value)) == value
  end
end
