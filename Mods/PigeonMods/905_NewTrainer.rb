# Override PBTrainers to add more Trainer ID's
module PBTrainers
  MODDED_LEADER_Brock = 500

end


  



# Add trainers
Events.onMapChange += proc {
  if $game_map.map_id == 386    # Brock gym
    TrainerHandler.spawn_trainer_event(
      tr_type: :MODDED_LEADER_Brock, 
      tr_name: "Brock", 
      tr_version: 0, 
      pokemon_data: [
        { species: :PIKACHU, level: 15 }, 
        { species: :CHARMANDER, level: 10 }
      ], 
      map_id: 386, 
      event_id: 2000, 
      x: 6, 
      y: 11, 
      page_list: [
        RPG::EventCommand.new(101, 0, ["Let's battle!"]),
        RPG::EventCommand.new(401, 0, ["Are you ready?"]),
        RPG::EventCommand.new(355, 0, ["pbTrainerBattle(:MODDED_LEADER_Brock,'Brock',_I('I took you for granted!'),false,0,false)"]),
        RPG::EventCommand.new(115) # End event processing
      ],
      sprite_name: "BWAssistant_male",
    )
  end
}
