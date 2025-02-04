# Function to dump all properties of an object to a file
def dump_object_properties(obj, file, depth = 0, max_depth = 3)
  return if depth > max_depth
  indentation = '  ' * depth
  if (depth == 0)
    file.puts("#{indentation}Object Properties for #{obj.class}:")
  end
  
  if (obj.instance_variables.length == 0)
    file.puts("#{indentation}  #{obj}   \t#{obj.class}")
    return
  end

  obj.instance_variables.each do |var|
    begin
      value = obj.instance_variable_get(var)

      # Open up arrays!
      if (value.is_a?(Array) || value.is_a?(Hash))
        file.puts("#{indentation}  #{var}: [")
        if (value.length > 70)
          file.puts("#{indentation}    [Array too long to display - #{value.length} elements]")
        else
          value.each do |element| 
            dump_object_properties(element, file, depth + 1, max_depth + 1)
          end
        end
        file.puts("#{indentation}  ]")
      else
        file.puts("#{indentation}  #{var}: #{value.inspect}   \t#{value.class}")
        if (value.class.name.include?("::"))
          dump_object_properties(value, file, depth + 1, max_depth)
        end 
      end
    rescue => e
      file.puts("#{indentation}  #{var}: [Error reading property: #{e.message}]")
    end
  end
end


# Export trainer data to a file
def export_trainer_data
  begin
    # File where data will be written (overwrite the file each time)
    File.open("trainer_export.txt", "w") do |file|
      file.puts("Trainer Data Dump:")
      file.puts("=================")

      # Dump $Trainer object
      file.puts("\n$Trainer Data:")
      dump_object_properties($Trainer, file)

      # Dump each Pokemon in the party
      file.puts("\nParty Data:")
      $Trainer.party.each_with_index do |pokemon, index|
        file.puts("\nPokemon ##{index + 1}:")
        dump_object_properties(pokemon, file)
      end

      # Dump PC storage (if exists and applicable)
      if $PokemonStorage
        file.puts("\nStored Box Data:")
        $PokemonStorage.boxes.each_with_index do |box, box_index|
          file.puts("\nBox #{box_index + 1}:")
          box.length.times do |slot_index|
            pokemon = box[slot_index]
            next unless pokemon  # Skip empty slots
            file.puts("\n  Slot #{slot_index + 1}:")
            dump_object_properties(pokemon, file, 1, 4)
          end
        end
      end
    end
    log_message("Trainer data exported to trainer_export.txt.")
  rescue => e
    log_message("An error occurred while exporting trainer data: #{e.message}")
  end
end


# Export species data to a file
def export_species_data
  begin
    # File where data will be written
    File.open("species_export.txt", "w") do |file|
      file.puts("Species Data Dump:")
      file.puts("=================")

      # Iterate through all species in the game
      GameData::Species.each do |species|
        species_data = species

        # Skip fusion Pokémon if necessary
        next if species_data.id_number > 520

        # Write relevant data
        file.puts("ID Number: #{species_data.id_number}")
        file.puts("Name: #{species_data.real_name}")
        file.puts("Pokedex Entry: #{species_data.real_pokedex_entry}")
        file.puts("--------------------------")
      end
    end
    log_message("Species data exported to species_export.txt.")
  rescue => e
    log_message("An error occurred while exporting species data: #{e.message}")
  end
end


def export_map_data
  begin
    # File where data will be written
    File.open("map_export.txt", "w") do |file|
      file.puts("Map Data Dump:")
      file.puts("=================")

      map = $game_map

      dump_object_properties(map, file)

      # Dump events data
      file.puts("\nEvents Data:")
      map.events.each do |event_id, event|
        file.puts("\nEvent ID: #{event_id}")
        dump_object_properties(event, file, 1, 4)
      end
    end
    log_message("Map data exported to map_export.txt.")
  rescue => e
    log_message("An error occurred while exporting map data: #{e.message}")
  end
end

# Export all trainers and their TrainerType data to a file
def export_all_trainers_data
  begin
    # File where trainer data will be written
    File.open("trainers_export.txt", "w") do |file|
      file.puts("All Trainers Data Dump:")
      file.puts("=========================\n")
      
      # Iterate through all trainers in the game
      GameData::Trainer.list_all.each do |key, trainer_data|
        file.puts("Trainer ID: #{key}")
        
        # Dump the trainer data using the provided method
        dump_object_properties(trainer_data, file, 1, 3)
        
        file.puts("\n--------------------------\n")
      end
    end
    
    File.open("modern_trainers_export.txt", "w") do |file|
      GameData::TrainerModern.list_all.each do |key, trainer_data|
        file.puts("Trainer ID: #{key}")
        
        # Dump the trainer data using the provided method
        dump_object_properties(trainer_data, file, 1, 3)
        
        file.puts("\n--------------------------\n")
      end
    end
    log_message("All trainers data exported to trainers_export.txt, modern_trainers_export.txt.")
  rescue => e
    log_message("An error occurred while exporting trainers data: #{e.message}")
  end
end


class SaveDumper
  # Only dump once ever
  @@dumped = false

  def self.dumped
    @@dumped
  end
  def self.dumped=(value)
    @@dumped = value
  end
end

save_dump_proc = proc {
  if (!SaveDumper.dumped && $Trainer)
    SaveDumper.dumped = true
    # export_species_data
    # export_all_trainers_data
    # Events.onMapChange.delete(save_dump_proc)
  end
}

Events.onMapChange += save_dump_proc



# Thread.new {
#   loop do
#     # Log player's position and rotation
#     if ($game_player)
#       log_message("Player Position: #{$game_player.x}, #{$game_player.y}, #{$game_player.direction}")
#     end
#     sleep(1)
#   end
# }







