# ###################################################################################################
# # Author: An Unsocial Pigeon                                                                      #
# # Discord: @anunsocialpigeon                                                                      #
# # For any issues or inquiries, feel free to reach out on Discord.                                 #
# #                                                                                                 #
# # You are allowed to use this file in your own mod,                                               # 
# # on condition that you correctly credit me (An Unsocial Pigeon) <3                               #
# ###################################################################################################



# # Follower Pokémon System
# class FollowerPokemon
#   attr_accessor :event

#   @player_positions = []
#   @player_map = nil
#   @player_is_moving = 0
  
#   def initialize
#     @event = nil
#     @player_positions = []
#     @player_map = nil
#     @player_is_moving = 0
#   end

#   # Update the follower's position and direction
#   def update
#     return unless @event && $game_player

#     player = $game_player
    
#     # Initialize positions when the follower is first set up
#     if @player_positions.empty?
#       @player_positions << [player.x, player.y]
#       @player_positions << [player.x, player.y]  # Added twice for proper tracking
#       @player_map = $game_map.map_id
#       @player_is_moving = 0
#       return
#     end

#     # Update follower anim speed
#     @player_is_moving -= 1 if @player_is_moving > 0
#     update_follower_speed(player, @player_is_moving > 0)
    
#     # Player hasn't moved
#     return if [player.x, player.y] == @player_positions.last
    
    
#     # Player has moved
#     @player_positions << [player.x, player.y]
#     @player_positions.shift if @player_positions.size > 2
#     @player_is_moving = 6
    
#     target_x, target_y = @player_positions.first
    
#     # Move the follower to the target position
#     if (@event.x - target_x).abs > 1 || (@event.y - target_y).abs > 1
#       @event.moveto(target_x, target_y)
#     elsif @event.x < target_x && @event.y < target_y
#       @event.move_lower_right
#     elsif @event.x < target_x && @event.y > target_y
#       @event.move_upper_right
#     elsif @event.x > target_x && @event.y < target_y
#       @event.move_lower_left
#     elsif @event.x > target_x && @event.y > target_y
#       @event.move_upper_left
#     elsif @event.x < target_x
#       @event.move_right
#     elsif @event.x > target_x
#       @event.move_left
#     elsif @event.y < target_y
#       @event.move_down
#     elsif @event.y > target_y
#       @event.move_up
#     else
#       # log_message("No movement?")
#     end
#   end

#   # Run if trainer is running, walk if player is walking.
#   def update_follower_speed(player, is_moving)
#     return unless @event
#     @event.move_speed = is_moving ? player.move_speed : 3   # Default to 3 when player is still
#     @event.move_frequency = player.pbIsRunning? ? 6 : 4
#   end

#   def adjacent_to_player?
#     (@event.x - $game_player.x).abs + (@event.y - $game_player.y).abs == 1
#   end

#   # Set the follower to a specific event
#   def set_follower(follower_event_id)
#     return if @event
#     @event = $game_map.events[follower_event_id]
#     @event.name
    
#     return unless @event
#     place_next_to_player
#     @event.through = true
#     @player_is_moving = 0
#   end

#   # Clear the follower event
#   def clear_follower
#     if @event
#       $game_map.events.delete(@event.id) if $game_map && @event 
#       @event.character_name = ""
#       @event = nil
#       @player_is_moving = 0
#     end
#   end

#   def place_next_to_player
#     return unless @event
  
#     # Default to player's position as fallback
#     target_x = $game_player.x
#     target_y = $game_player.y
  
#     # Determine the best adjacent position
#     case $game_player.direction
#     when 2 # Down
#       target_y -= 1
#     when 4 # Left
#       target_x += 1
#     when 6 # Right
#       target_x -= 1
#     when 8 # Up
#       target_y += 1
#     end
  
#     # Ensure the target position is valid
#     if target_x < 0 || target_y < 0 || target_x >= $game_map.width || target_y >= $game_map.height
#       target_x = $game_player.x
#       target_y = $game_player.y
#     end
  
#     @event.moveto(target_x, target_y)
#     @player_is_moving = 0
#   end
# end


# # Set up the follower Pokémon
# def setup_follower_pokemon
#   return unless !$Follower.event

#   lead_pokemon = $Trainer.first_pokemon
#   follower_event_id = 6969  # THIS MUST BE UNIQUE!!!!!

#   return $Follower.clear_follower unless lead_pokemon
#   return unless $game_map.events[follower_event_id]

#   if lead_pokemon && $game_map.events[follower_event_id]
#     # Fusion case
#     if lead_pokemon.species_data.is_a?(GameData::FusedSpecies)
#       base_path = "Graphics/Characters/Followers"
#       modded_output = "OverwolrdFusions"

#       head_id = lead_pokemon.species_data.head_pokemon.species
#       body_id = lead_pokemon.species_data.body_pokemon.species

#       # Create the follower sprite if it doesn't exist.
#       unless File.exist?("#{base_path}/#{modded_output}/#{lead_pokemon.species}.png")
#         log_message("Follower fusion base doesn't exist... Making it!")
#         create_combined_sprite("#{base_path}/#{head_id}", "#{base_path}/#{body_id}", "#{base_path}/#{modded_output}/#{lead_pokemon.species}.png")
#       end

#       follower_sprite = "Followers/#{modded_output}/#{lead_pokemon.species}"
#     end
    
#     # If not fusion
#     follower_sprite = "Followers/#{lead_pokemon.species}#{lead_pokemon.form > 0 ? "_#{lead_pokemon.form}" : ""}" if !follower_sprite

#     # Give the game object created before this id.
#     $game_map.events[follower_event_id].character_name = follower_sprite
    
#     $Follower.set_follower(follower_event_id)

#   else
#     # Clear the follower if there's no lead Pokémon or event
#     $Follower.clear_follower
#   end
# end


# # Modify the Scene_Map class to handle follower updates
# class Scene_Map
#   # Alias existing methods to preserve original functionality
#   alias follower_update update

#   # Update the map and follower system each frame
#   def update
#     follower_update
#     $Follower.update if $Follower
#   end
# end


# # Modify the pokemon party screen to handle follower update
# class PokemonPartyConfirmCancelSprite
#   alias original_dispose dispose

#   def dispose
#     original_dispose
#     create_follower
#   end
# end



# def create_combined_sprite(head_sprite_path, body_sprite_path, output_path)
#   # Load the two bitmaps
#   head_sprite = Bitmap.new(head_sprite_path)
#   body_sprite = Bitmap.new(body_sprite_path)

#   # Ensure sprites are the same pixel height
#   if head_sprite.height != body_sprite.height
#     raise "Sprites must be the same height to combine"
#   end

#   # Determine dimensions for combining
#   width = head_sprite.width
#   height = head_sprite.height

#   # Create a new bitmap to hold the combined sprite
#   combined_sprite = Bitmap.new(width, head_sprite.height)

#   # Iterate over each sprite in the 4x4 grid
#   (0...4).each do |i|
#     bias = height / 32

#     # Calculate the position of the current sprite in the grid
#     y = i * (height / 4)
#     x = 0

#     # Draw the top half of the current sprite from sprite 1
#     rect_top = Rect.new(x, y, width, (height / 8) + bias)
#     combined_sprite.blt(x, y, head_sprite, rect_top)

#     # Draw the bottom half of the current sprite from sprite 2
#     rect_bottom = Rect.new(x, y + (height / 8) + bias, width, height / 8 - bias)
#     combined_sprite.blt(x, y + (height / 8) + bias, body_sprite, rect_bottom)
#   end

#   # Save the combined sprite
#   dir = File.dirname(output_path)
#   Dir.mkdir(dir) unless Dir.exist?(dir)

#   # Save the combined sprite
#   combined_sprite.save_to_png(output_path)

#   # Dispose of the bitmaps to free memory
#   head_sprite.dispose
#   body_sprite.dispose
#   combined_sprite.dispose
# end



# def initialize_trainer_with_follower
#   return unless $Trainer && $Trainer.first_pokemon

#   if !$Follower
#     $Follower = FollowerPokemon.new
#   end

#   if !$Follower.event
#     setup_follower_pokemon
#   end

#   setup_follower_pokemon if $Trainer && $Trainer.first_pokemon
# end


# def create_follower
#   follower_event_id = 6969

#   if ($game_map && $Trainer && $Trainer.first_pokemon)
#     $Follower.clear_follower if $Follower
    
#     TrainerHandler.create_sprite_event(
#       $game_map.map_id, 
#       follower_event_id, 
#       10, 
#       10, 
#       2, 
#       "", 
#       [RPG::EventCommand.new(101, 0, ["Hia! :3"])],
#       true
#     )
          
#     initialize_trainer_with_follower
#   end
# end


# Events.onMapChange += proc {
#   create_follower
# }
