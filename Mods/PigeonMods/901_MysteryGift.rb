# require_relative "Data/Scripts/998_Mods/101_TrainerHandler"
ModdedSave.register_mod(:mystery_gift)

# Mystery Gift event
Events.onMapChange += proc { |_sender, _e|
  current_map_id = $game_map.map_id

  # Add a new trainer if on a specific map
  if current_map_id == 129 # Pokecentre, upstairs = 129 -> Vermilloin city trainer school (debug) = 458
    last_gift_time = ModdedSave.load_mod_data(:wonder_trade, :last_gift_time) || 0

    response = OnlineUtils.http_get("#{OnlineEnvironment.base_url}/is_mystery_gift_available?time=#{last_gift_time}")
    if response.nil? || response[:body] != "True"
      next
    end

    page_list = [
      # Initial Dialogue
      RPG::EventCommand.new(101, 0, ["There is a mystery gift waiting for you!"]),
      RPG::EventCommand.new(101, 0, ["Do you wish to accept?"]),
      RPG::EventCommand.new(102, 0, [["Yes", "No"], 2]),

      # Yes
      RPG::EventCommand.new(402, 0, [0]),  
      RPG::EventCommand.new(355, 1, ["begin; ModMysteryGift.GetMysteryGift(); end"]),
      RPG::EventCommand.new(101, 1, ["Enjoy your gift!"]),
      RPG::EventCommand.new(214, 1, ["self_switch", "A", true]),
      RPG::EventCommand.new(0, 1, []),  
      RPG::EventCommand.new(115, 1, []),

      # No 
      RPG::EventCommand.new(402, 0, [1]),  
      RPG::EventCommand.new(101, 1, ["Aweh... Too bad!"]),
      RPG::EventCommand.new(0, 1, []),  
      RPG::EventCommand.new(115, 1, []), 

      # Fallback End
      RPG::EventCommand.new(404, 0, []),
      RPG::EventCommand.new(0, 0, [])
    ]

    TrainerHandler.create_sprite_event(current_map_id, 70, 14, 7, 4, "225_0", page_list, true)
  end
}


module ModMysteryGift
  # Get a mystery gift
  def self.GetMysteryGift
    # Server IPs
    ip = "#{OnlineEnvironment.base_url}/mystery_gift"
    
    response = OnlineUtils.http_get(ip)

    unless response
      log_message("Failed to retrieve mystery gift.")
      return false
    end

    begin
      gift = response[:body].split(",")

      if gift.nil? || gift.empty? || gift.length < 2
        log_message("Error: Gift data is empty or invalid. Received: #{gift}")
        return false
      end

      # Create the Pokemon
      pokemon_name = gift[0]
      pokemon_level = gift[1].to_i

      begin
        pokemon = Pokemon.new(pokemon_name, pokemon_level)
        pbAddPokemon(pokemon)
        ModdedSave.save_mod_data(:wonder_trade, :last_gift_time, Time.now)
        log_message("Mystery Gift received: #{pokemon_name} at level #{pokemon_level}. Added to inventory.")
        return true
      rescue => e
        log_message("Error creating or adding Pokemon: #{e.message}")
        return false
      end
    rescue => e
      log_message("Error processing mystery gift data: #{e.message}")
      return false
    end
  end
end

