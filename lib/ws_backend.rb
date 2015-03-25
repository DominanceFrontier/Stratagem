require 'faye/websocket'
require 'thread'
require 'redis'
require 'json'
require 'erb'
require 'open3'

module TicTacToe
  
  class WsBackend
    KEEPALIVE_TIME = 15 # in seconds

    def initialize(app)
      @app     = app
      @channel_list = ["global"]
      @channels = {"global" => []}
      @clients = {}
      #uri = URI.parse(ENV["REDISTOGO_URL"])
      @redis = Redis.new(:url => ENV['REDISTOGO_URL'])
      @thr = Thread.new { puts 'Hello, World!' }
      subscribe
    end

    def call(env)
      if Faye::WebSocket.websocket?(env)
        
        # WebSockets logic goes here
        ws = Faye::WebSocket.new(env, nil, {ping: KEEPALIVE_TIME})
        ws.on :open do |event|
          p [:open, ws.object_id]
          ws_id = ws.object_id.to_s
          @channels["global"] << ws
          @clients[ws_id] = "global"
          msg = { "welcome" => ws_id }
          @redis.publish(@clients[ws_id], JSON.generate(msg))
          p @clients[ws_id]
        end

        ws.on :message do |event|
          p [:message, event.data]
          ws_id = ws.object_id.to_s
          #
          # If trying to open a new connection, kill the subscription thread
          # and run it again after updating all the channels and client info
          # Else just past the message along
          #
          # Consider creating a new thread for each channel instead
          #
          if event.data.include? "ch"
            msg = JSON.parse(event.data)
            @channels[@clients[ws_id]].delete(ws)
            @channel_list << msg["ch"]
            @clients[ws_id] = msg["ch"]
            if @channels.has_key? msg["ch"]
              @channels[msg["ch"]] << ws
            else
              @channels[msg["ch"]] = [ws]
            end
            subscribe
          else
            @redis.publish(@clients[ws_id], sanitize(event.data))
          end
          p @clients[ws_id]
        end

        ws.on :close do |event|
          p [:close, ws.object_id, event.code, event.reason]
          ws_id = ws.object_id.to_s
          @channels[@clients[ws_id]].delete(ws)
          @clients.delete(ws_id)
          ws = nil
        end
        
        # Return async Rack response
        ws.rack_response
      else
        @app.call(env)
      end
    end

    private
    
    def sanitize(message)
      json = JSON.parse(message)
      json.each {|key, value| json[key] = ERB::Util.html_escape(value) }
      JSON.generate(json)
    end

    def subscribe
      @thr.exit
      @thr = Thread.new do
        redis_sub = Redis.new(:url => ENV['REDISTOGO_URL'])
        redis_sub.subscribe(@channel_list) do |on|
          on.message do |channel, msg|
            p [channel, msg]
            @channels[channel].each {|ws| ws.send(msg) }
          end
        end
      end
    end
    
  end
  
end
