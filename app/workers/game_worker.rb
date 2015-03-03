# app/workers/game_worker.rb
class GameWorker
  include Sidekiq::Worker

  def perform
    while true do
      redis = Redis.new(:url => ENV['REDISTOGO_URL'])
      redis.publish("chat-demo", "{\"handle\":\"lolol\",\"text\":\"trololol\"}")
    end
  end
end
