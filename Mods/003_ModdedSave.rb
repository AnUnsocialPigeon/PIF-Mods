module ModdedSave
  SAVE_DIR = if File.directory?(System.data_directory)
      System.data_directory
    else
      '.'
    end
  
  GLOBAL_FILE = "#{SAVE_DIR}/Global_ModdedSave.rxdata"

  @mod_data = {}
  @registered_mods = []

  class << self
    attr_reader :registered_mods

    # Registers a mod with the modded save system
    # @param mod_name [Symbol] the unique name of the mod
    def register_mod(mod_name)
      validate mod_name => Symbol
      unless @registered_mods.include?(mod_name)
        @registered_mods << mod_name
        @mod_data[mod_name] ||= {}
      end
    end

    # Saves mod-specific data into the namespace
    # @param mod_name [Symbol] the unique name of the mod
    # @param key [Symbol] the key for the data
    # @param value [Object] the data to store
    def save_mod_data(mod_name, key, value)
      validate mod_name => Symbol, key => Symbol
      register_mod(mod_name) unless @registered_mods.include?(mod_name)
      modded_data = load_current_save
      modded_data[mod_name] ||= {}
      modded_data[mod_name][key] = value
      save_current_save(modded_data)
    end

    # Loads mod-specific data from the namespace
    # @param mod_name [Symbol] the unique name of the mod
    # @param key [Symbol] the key for the data
    # @return [Object, nil] the stored data or nil if not found
    def load_mod_data(mod_name, key)
      validate mod_name => Symbol, key => Symbol
      modded_data = load_current_save
      modded_data.dig(mod_name, key)
    end

    # Saves global modded data
    # @param mod_name [Symbol] the unique name of the mod
    # @param key [Symbol] the key for the data
    # @param value [Object] the data to store
    def save_global_mod_data(mod_name, key, value)
      validate mod_name => Symbol, key => Symbol
      register_mod(mod_name) unless @registered_mods.include?(mod_name)
      global_data = load_global
      global_data[mod_name] ||= {}
      global_data[mod_name][key] = value
      save_global(global_data)
    end

    # Loads global modded data
    # @param mod_name [Symbol] the unique name of the mod
    # @param key [Symbol] the key for the data
    # @return [Object, nil] the stored data or nil if not found
    def load_global_mod_data(mod_name, key)
      validate mod_name => Symbol, key => Symbol
      global_data = load_global
      global_data.dig(mod_name, key)
    end

    # Helper to load the current save's modded data
    # Uses $Trainer.name and $Trainer.id to determine the file name
    def load_current_save
      file_path = current_save_file_path
      return {} unless File.file?(file_path)
      File.open(file_path, 'rb') { |file| Marshal.load(file) }
    rescue
      {}
    end

    # Helper to save the current save's modded data
    # Uses $Trainer.name and $Trainer.id to determine the file name
    def save_current_save(data)
      file_path = current_save_file_path
      File.open(file_path, 'wb') { |file| Marshal.dump(data, file) }
    end

    # Helper to get the file path for the current save's modded data  
    # Uses $Trainer.name and $Trainer.id to uniquely identify the file
    def current_save_file_path
      validate_trainer_context!
      "#{SAVE_DIR}/#{$Trainer.name}_#{$Trainer.id}_ModdedSave.rxdata"
    end

    # Helper to validate if $Trainer context is available
    def validate_trainer_context!
      raise "Trainer context is not available!" unless defined?($Trainer) && $Trainer
      raise "Trainer name or ID is missing!" if $Trainer.name.nil? || $Trainer.id.nil?
    end

    # Helper to save global data
    def save_global(data)
      File.open(GLOBAL_FILE, 'wb') { |file| Marshal.dump(data, file) }
    end

    # Helper to load global data
    def load_global
      return {} unless File.file?(GLOBAL_FILE)
      File.open(GLOBAL_FILE, 'rb') { |file| Marshal.load(file) }
    rescue
      {}
    end
  end
end
