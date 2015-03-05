# app/workers/game_worker.rb
class GameWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(match_id)
    for i in 0..5 do
      sleep 10
      redis = Redis.new(:url => ENV['REDISTOGO_URL'])
      redis.publish("global", "{\"handle\":\"lolol#{i}\",\"text\":\"trololol\"}")
    end
  end
end
