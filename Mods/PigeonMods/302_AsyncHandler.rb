class Async_Callbacks
  def initialize
    # Hash to store callback functions with their associated IDs
    @callbacks = {}
    @next_id = 1 # Incremental ID generator
  end

  # Add a callback function and return its unique ID
  def add_callback(proc)
    id = @next_id
    @callbacks[id] = proc
    @next_id += 1
    return id
  end

  # Remove a callback function by its ID
  def remove_callback(id)
    @callbacks.delete(id)
  end

  # Execute all stored callback functions
  def execute_callbacks
    @callbacks.each_value do |callback|
      callback.call
    end
  end
end

# Modify the Scene_Map class to include async updates
class Scene_Map
  alias original_update update

  def initialize
    super
    @async_callbacks = Async_Callbacks.new
  end

  def update
    original_update
    @async_callbacks.execute_callbacks
  end

  # Expose methods to add and remove callbacks via Scene_Map
  def add_async_callback(proc)
    return @async_callbacks.add_callback(proc)
  end

  def remove_async_callback(id)
    @async_callbacks.remove_callback(id)
  end
end




# # Add a callback to print "Hello, World!" during updates
# callback_id = scene_map.add_async_callback(Proc.new { puts "Hello, World!" })

# # Later, remove the callback by its ID
# scene_map.remove_async_callback(callback_id)
