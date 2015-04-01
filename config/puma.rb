workers 2
threads 1, 6

preload_app!

on_worker_boot do
  ActiveRecord::Base.establish_connection
end
