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
      @channels = {"global" => []}
      @clients = {}
      #uri = URI.parse(ENV["REDISTOGO_URL"])
      @redis = Redis.new(:url => ENV['REDISTOGO_URL'])
      @thr = Thread.new do
        redis_sub = Redis.new(:url => ENV['REDISTOGO_URL'])
        redis_sub.subscribe("global") do |on|
          on.message do |channel, msg|
            p [channel, msg]
            @channels[channel].each {|ws| ws.send(msg) }
          end
        end
      end
    end

    def call(env)
      if Faye::WebSocket.websocket?(env)
        
        # WebSockets logic goes here
        ws = Faye::WebSocket.new(env, nil, {ping: KEEPALIVE_TIME})
        ws.on :open do |event|
          p [:open, ws.object_id]
          @channels["global"] << ws
          @clients[ws.object_id.to_s] = "global"
          p @clients
        end

        ws.on :message do |event|
          p [:message, event.data]
          @redis.publish(@clients[ws.object_id.to_s], sanitize(event.data))
          p @clients[ws.object_id.to_s]
        end

        ws.on :close do |event|
          p [:close, ws.object_id, event.code, event.reason]
          @clients.delete(ws.object_id.to_s)
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

    def subscribe(msgchannel)
    end
    
  end
end
