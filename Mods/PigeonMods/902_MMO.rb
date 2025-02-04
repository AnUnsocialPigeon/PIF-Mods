require 'thread'

module MMO
  class OnlinePlayer
    attr_accessor :guid, :id, :map_id, :x, :y

    def initialize(guid, id, map_id, x, y)
      @guid = guid
      @id = id
      @map_id = map_id
      @x = x
      @y = y
    end
  end

  module OnlineEnvironment
    @online_players = {}
    @self_guid = nil
    @base_url = "http://localhost:3000"
    @is_online = true  
    @last_network_request = Time.now 
    @time_between_network_requests = 0.5
    @network_queue = Queue.new
    @response_queue = Queue.new

    def self.online_players
      @online_players
    end

    def self.self_guid
      @self_guid
    end

    def self.self_guid=(guid)
      @self_guid = guid
    end

    def self.base_url
      @base_url
    end

    def self.is_online
      @is_online
    end

    def self.network_queue
      @network_queue
    end

    def self.response_queue
      @response_queue
    end

    def self.last_network_request
      @last_network_request
    end

    def self.last_network_request=(time)
      @last_network_request = time
    end

    def self.time_between_network_requests
      @time_between_network_requests
    end

    def self.time_between_network_requests=(seconds)
      @time_between_network_requests = seconds
    end

    def self.has_enough_time_elapsed
      Time.now - @last_network_request >= @time_between_network_requests
    end
  end

  @network_thread = Thread.new do
    loop do
      request = OnlineEnvironment.network_queue.pop
      next unless request
      
      begin
        response = OnlineUtils.http_post(
          OnlineEnvironment.base_url,
          request
        )
        
        OnlineEnvironment.response_queue.push(response[:body]) if response
        OnlineEnvironment.last_network_request = Time.now
      rescue StandardError => e
        log_message("Network thread error: #{e.message}")
      end
    end
  end

  def self.initialize_mmo
    MMO::OnlineEnvironment.self_guid = OnlineUtils.http_get("#{OnlineEnvironment.base_url}/guid")[:body]
  end

  def self.tick
    map_id = $game_map.map_id
    x = $game_player.x
    y = $game_player.y
    rot = $game_player.direction

    request = { "map_id" => map_id, "x" => x, "y" => y, "rot" => rot, "guid" => MMO::OnlineEnvironment.self_guid }
    MMO::OnlineEnvironment.network_queue.push(request)
  end

  def self.process_responses
    while !MMO::OnlineEnvironment.response_queue.empty?
      response_body = MMO::OnlineEnvironment.response_queue.pop
      next unless response_body

      players = OnlineUtils.from_csv(response_body)
      players.each do |guid, player_data|
        player_info = player_data.split(",")
        player_guid = player_info[0]
        player_x = player_info[1].to_i
        player_y = player_info[2].to_i
        player_rot = player_info[3].to_i

        next if $game_player.x == player_x && $game_player.y == player_y

        player = MMO::OnlineEnvironment.online_players[guid]
        id = 269 + MMO::OnlineEnvironment.online_players.length

        if player.nil?
          MMO::OnlineEnvironment.online_players[guid] = OnlinePlayer.new(player_guid, id, $game_map.map_id, player_x, player_y)
          TrainerHandler.create_sprite_event($game_map.map_id, id, player_x, player_y, player_rot)
            log_message("Added new player #{guid} at position (#{player_x}, #{player_y}) with rotation #{player_rot}")
        else
          $game_map.events[id]&.moveto(player_x, player_y)
          $game_map.events[id]&.set_direction(player_rot)
          log_message("Updated player #{guid} position to (#{player_x}, #{player_y}) with rotation #{player_rot}")
        end
      end
    end
  end
end

class Scene_Map
  alias old_update update

  def update
    old_update
    return unless MMO::OnlineEnvironment.is_online && MMO::OnlineEnvironment.has_enough_time_elapsed

    MMO.initialize_mmo unless MMO::OnlineEnvironment.self_guid
    MMO.tick
    MMO.process_responses
  end
end
