# You must change the NB_POKEMON constant in Settings overwrite when adding pokemon!

module CustomPokemonInjector
  @new_pokemon_count = 0

  class << self
    attr_accessor :new_pokemon_count
  end

  def self.increment_pokemon_count
    @new_pokemon_count += 1
  end

  def self.add_custom_pokemon(pokemon_data)
    CustomPokemonInjector.increment_pokemon_count
    new_pokemon_id = Settings::NB_POKEMON_INITIAL + CustomPokemonInjector.new_pokemon_count
  
    # Define the Pokémon's properties using GameData::Species.register
    GameData::Species.register({
      :id => pokemon_data[:name].upcase.to_sym, # ID must be a symbol
      :id_number => new_pokemon_id,
      :name => pokemon_data[:name].upcase,
      :form_name => pokemon_data[:form_name],
      :category => pokemon_data[:category],
      :pokedex_entry => pokemon_data[:pokedex_entry],
      :type1 => pokemon_data[:type1],
      :type2 => pokemon_data[:type2],
      :base_stats => pokemon_data[:base_stats],
      :gender_ratio => pokemon_data[:gender_ratio],
      :growth_rate => pokemon_data[:growth_rate],
      :base_exp => pokemon_data[:base_exp],
      :effort_points => pokemon_data[:effort_points],
      :rareness => pokemon_data[:rareness],
      :happiness => pokemon_data[:happiness],
      :abilities => pokemon_data[:abilities],
      :hidden_abilities => pokemon_data[:hidden_abilities],
      :moves => pokemon_data[:moves],
      :tutor_moves => pokemon_data[:tutor_moves],
      :egg_moves => pokemon_data[:egg_moves],
      :evolutions => pokemon_data[:evolutions],
      :incense => pokemon_data[:incense]
    })
  
    # Add to gamee data
    GameData::NAT_DEX_MAPPING[new_pokemon_id] = pokemon_data[:nat_dex_mapping]
    GameData::SPLIT_NAMES << pokemon_data[:name_parts]
  
    log_message("Successfully added new Pokémon: #{pokemon_data[:name]} (ID: #{new_pokemon_id}) (Total: #{NB_POKEMON})")
  end
end

# Example usage
elgyem_pokemon = {
  :name => "Elgyem",
  :name_parts => ["Elgy", "Em"],
  :form_name => nil,
  :category => "Cerebral",
  :pokedex_entry => "This Pokémon is said to have come from outer space. It has powerful psychic abilities.",
  :type1 => :PSYCHIC,
  :type2 => nil,
  :base_stats => { :HP => 55, :ATTACK => 55, :DEFENSE => 55, :SPATK => 85, :SPDEF => 55, :SPEED => 30 },
  :gender_ratio => :Genderless,
  :growth_rate => :Medium,
  :base_exp => 67,
  :effort_points => { :SPATK => 1 },
  :rareness => 255,
  :happiness => 70,
  :abilities => [:TELEPATHY, :SYNCHRONIZE],
  :hidden_abilities => [:ANALYTIC],
  :moves => [
    [1, :CONFUSION],
    [4, :GROWL],
    [8, :HEALBLOCK],
    [12, :MIRACLEEYE],
    [16, :PSYBEAM],
    [20, :HEADBUTT],
    [24, :HIDDENPOWER],
    [28, :IMPRISON],
    [32, :PSYCHIC],
    [36, :CALMMIND],
    [40, :ZENHEADBUTT],
    [44, :RECOVER],
    [48, :GUARDSWAP],
    [52, :POWERUPPUNCH]
  ],
  :tutor_moves => [:THUNDERWAVE, :TRICKROOM, :ALLYSWITCH],
  :egg_moves => [],
  # :evolutions => [{ :BEHEEYEM, :Level, 42, true }],
  :evolutions => [],
  :incense => nil,
  :nat_dex_mapping => 605,
}



# # Inject, but only once
# class SpeciesInjector
#   # Only dump once ever
#   @@injected = false
  
#   def self.injected
#     @@injected
#   end
#   def self.injected=(value)
#     @@injected = value
#   end
# end

# Events.onMapChange += proc {
#   if (!SpeciesInjector.injected && $Trainer)
#     CustomPokemonInjector.add_custom_pokemon(elgyem_pokemon)
#     # export_species_data
#     SpeciesInjector.injected = true
#   end
# }
