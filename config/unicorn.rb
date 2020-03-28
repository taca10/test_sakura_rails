# APP_PATH = "/var/www/html/test_sakura_rails"

# worker_processes 4
# working_directory APP_PATH
# listen "/var/run/unicorn/unicorn.socket"
# pid APP_PATH + "/tmp/pids/unicorn.pid"
# stderr_path APP_PATH + "/log/unicorn.log"
# stdout_path APP_PATH + "/log/unicorn.log"

# preload_app true

# before_fork do |server, worker|
#   ActiveRecord::Base.connection.disconnect!

#   old_pid = "#{server.config[:pid]}.oldbin"
#   if old_pid != server.pid
#     begin
#       sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
#       Process.kill(sig, File.read(old_pid).to_i)
#     rescue Errno::ENOENT, Errno::ESRCH
#     end
#   end
# end

# after_fork do |server, worker|
#   ActiveRecord::Base.establish_connection
# end


unicorn_path = "/var/log/unicorn"
# working_directory "#{unicorn_path}/current"

listen "#{unicorn_path}/unicorn.sock"
pid "#{unicorn_path}/unicorn.pid"

log = "#{unicorn_path}/unicorn.log"
stdout_path "#{unicorn_path}/unicorn-stdort.log"
stderr_path "#{unicorn_path}/unicorn-stderr.log"

worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3)
timeout 15
preload_app true

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end
