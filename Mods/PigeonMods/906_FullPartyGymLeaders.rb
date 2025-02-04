###################################################################################################
# Author: An Unsocial Pigeon                                                                      #
# Discord: @anunsocialpigeon                                                                      #
# For any issues or inquiries, feel free to reach out on Discord.                                 #
#                                                                                                 #
# You are allowed to use this file in your own mod,                                               # 
# on condition that you correctly credit me (An Unsocial Pigeon) <3                               #
###################################################################################################



module TeamOverwriteManager
  def self.descale_team_from_max_team(trainer_id)
    # log_message("Descaling team for trainer ID: #{trainer_id}")
    
    # Process both classic and modern trainer data
    process_clones(GameData::Trainer, trainer_id, false)
    process_clones(GameData::TrainerModern, trainer_id, true)

  end

  def self.process_clones(trainer_data_module, trainer_id, is_modern)
    # Fetch all clones of a trainer id
    clones = trainer_data_module.list_all.each_with_object([]) do |(_, trainer_data), result|
      result << trainer_data if trainer_data.trainer_type == trainer_id
    end
    return if clones.empty?
    clones = clones.uniq { |trainer_data| [trainer_data.trainer_type, trainer_data.real_name, trainer_data.version] }

    # Descale clones
    descaled_clones = descale_clones(clones)

    # Update trainers
    descaled_clones.each do |clone_data|
      # log_message("Clone ID: #{clone_data.trainer_type}, Name: #{clone_data.real_name}, Version: #{clone_data.version}, Pokemon: #{clone_data.pokemon.map { |pokemon| "#{pokemon[:species]} (Level #{pokemon[:level]})" }.join(', ')}")
      TrainerHandler.set_trainer(
        clone_data.trainer_type,
        clone_data.real_name,
        clone_data.version,
        clone_data,
        is_modern
        )
      # increase_player_pokemon_count_to_max()
    end
  end

  def self.descale_clones(clones)
    # Find strongest clone, by total level of evey pokemon on the team.
    strongest_clone = clones.max_by do |trainer_data|
      trainer_data.pokemon.map { |pokemon| pokemon[:level] }.sum 
    end
    strongest_clone_index = clones.index(strongest_clone)
    pokemon_count = strongest_clone.pokemon.length
    
    # log_message("Strongest clone found: Trainer ID: #{strongest_clone.trainer_type}, Name: #{strongest_clone.real_name}, Version: #{strongest_clone.version}, Total Level: #{strongest_clone.pokemon.map { |pokemon| pokemon[:level] }.sum}")

    clones.each_with_index do |clone_data, index|
      next if index == strongest_clone_index
        
      # Get level bounds
      max_level = clone_data.pokemon.map { |pokemon| pokemon[:level] }.max
      min_level = clone_data.pokemon.map { |pokemon| pokemon[:level] }.min

      clone_data.pokemon = []

      # For each of the strongest clone's pokemon, extract it, descale it, and give it to the clone.
      strongest_clone.pokemon.each_with_index do |strongest_pokemon, i|
        pokemon = strongest_pokemon.dup

        pokemon[:level] = pokemon_count <= 1 ? min_level.round(0) : (((max_level - min_level) * (i.to_f / (pokemon_count - 1))) + min_level).round(0)
        pokemon.delete(:moves)
        pokemon.delete(:ability_index)

        # Fusion
        if pokemon[:species].to_s.match?(/^B\d+H\d+$/)
          species_data = GameData::FusedSpecies.get(pokemon[:species])
          head = species_data.head_pokemon
          body = species_data.body_pokemon
          
          head_id_scaled = get_species_at_given_level(pokemon[:level], head)
          body_id_scaled = get_species_at_given_level(pokemon[:level], body)

          head_id_numeric = GameData::Species.get(head_id_scaled.to_sym).id_number
          body_id_numeric = GameData::Species.get(body_id_scaled.to_sym).id_number

          pokemon[:species] = "B#{body_id_numeric.to_s}H#{head_id_numeric.to_s}".to_sym
        else
          # Non-fusion
          species_data = GameData::Species.get(pokemon[:species])
          pokemon[:species] = get_species_at_given_level(pokemon[:level], species_data)
        end

        # Append to the clone's pokemon
        clone_data.pokemon << pokemon
      end

      # Inject the new team into memory
      # log_message("Injecting new team for trainer ID: #{clone_data.trainer_type}, Name: #{clone_data.real_name}, Version: #{clone_data.version}")
    end

    return clones
  end

  def self.get_species_at_given_level(level, current_species)
    # Get the baby pokemon of the chain
    # log_message("Getting evolution chain at level #{level} for #{current_species.species}")

    pokemon = GameData::Species.get(current_species.get_baby_species().to_sym)
    evolves_into_level = 0
    chain = [[pokemon.species, evolves_into_level]]

    # No evo tree should be longer than 10. This is to ensure no infinite loops!
    depth = 10
    while depth > 0
      depth -= 1

      # Get all pokemon the pokemon turns into
      evos = pokemon.get_evolutions()
      break if evos.empty?
      
      # randomise order to randomise which chain we go up. May add bugs / edge cases, but, who cares I CBA :P
      # log_message("All evo values: #{evos.map { |evo| evo.join(', ') }.join(' | ')}")
      evos.shuffle! 
      evo = evos.first

      # log_message("Chosen evo value: #{evo.join(', ')}")

      # Update the evo level
      if [:Level, :LevelNight, :LevelDay].include?(evo[1])
        evolves_into_level = evo[2]
        break if evolves_into_level > level
      end
      
      # Append the pokemon
      chain << [evo[0], evolves_into_level]
      pokemon = GameData::Species.get(evo[0])
    end

    # log_message("Evolution chain for species #{current_species.species}: #{chain.map { |species, level| "#{species} (Level #{level})" }.join(' -> ')}")
    # log_message("")
    return chain.last[0]
  end

  # Override trainer's teams with the teams found in the ModData directory
  def self.overwrite_trainer_teams_from_mod_data()
    # Read the mod data file
    mod_data_dir = BaseGameType.get_base_game_type == "PIF" ? "ModData" : "Mods/ModData"
    return unless Dir.exist?(mod_data_dir)  
    
    files = Dir.glob(File.join(mod_data_dir, '*')).select { |file| File.file?(file) }
    return unless files

    files.each do |file_path|
      lines = File.readlines(file_path)
      
      # Extract which trainer this is for
      first_line = lines.first
      trainer_id, trainer_name, trainer_version = first_line.strip.split(',')
      
      trainer = TrainerHandler.get_trainer(trainer_id.strip.to_sym, trainer_name.strip, trainer_version.strip.to_i)
      next unless trainer
      
      # Insert the pokemon from the file
      trainer.pokemon = []
      lines.each_with_index do |line, index|
        next if index == 0 || !line.strip.match?(/^[A-Za-z0-9_]+,\d+$/)

        # Split
        parts = line.split('#').first.strip.split(',')
        next if parts.length < 2
        
        # Disect the line
        species, level = parts

        trainer.pokemon << { 
          species: species.strip.to_sym, 
          level: level.strip.to_i 
        }
      end

      # Reset the trainer
      # log_message("Overwriting trainer #{trainer_id}, #{trainer_name}, #{trainer_version}")
      TrainerHandler.set_trainer(trainer_id.strip.to_sym, trainer_name.strip, trainer_version.strip.to_i, trainer)
    end
  end
end



class TeamInjectionTracker
  # Only dump once ever
  @@injected = false

  def self.injected
    @@injected
  end
  def self.injected=(value)
    @@injected = value
  end
end

Events.onMapChange += proc {
  if (!TeamInjectionTracker.injected && $Trainer)
    TeamInjectionTracker.injected = true
    
    # Descale 
    TeamOverwriteManager.descale_team_from_max_team(:LEADER_Brock)
    TeamOverwriteManager.descale_team_from_max_team(:LEADER_Misty)
    TeamOverwriteManager.descale_team_from_max_team(:LEADER_Surge)
    TeamOverwriteManager.descale_team_from_max_team(:LEADER_Erika)
    TeamOverwriteManager.descale_team_from_max_team(:LEADER_Koga)
    TeamOverwriteManager.descale_team_from_max_team(:LEADER_Sabrina)
    TeamOverwriteManager.descale_team_from_max_team(:LEADER_Blaine)
    TeamOverwriteManager.descale_team_from_max_team(:LEADER_Giovanni)

    TeamOverwriteManager.descale_team_from_max_team(:LEADER_Whitney)
    TeamOverwriteManager.descale_team_from_max_team(:LEADER_Kurt)
    TeamOverwriteManager.descale_team_from_max_team(:LEADER_Falkner)
    TeamOverwriteManager.descale_team_from_max_team(:LEADER_Clair)
    TeamOverwriteManager.descale_team_from_max_team(:LEADER_Morty)
    TeamOverwriteManager.descale_team_from_max_team(:LEADER_Pryce)
    TeamOverwriteManager.descale_team_from_max_team(:LEADER_Jasmine)
    TeamOverwriteManager.descale_team_from_max_team(:LEADER_Chuck)

    # Overwrite all with any manual teams
    # TeamOverwriteManager.overwrite_trainer_teams_from_mod_data()
  end
}



