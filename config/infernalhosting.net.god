# file:      infernalhosting.net.god
# run with:  god start -c /www/infernalhosting.net/current/config/infernalhosting.net.god

RAILS_ROOT = "/www/infernalhosting.net/current"

God.meddle do |god|
  %w{1666 1667 1668}.each do |port|
    god.watch do |w|
      w.name = "infernalhosting.net-mongrel-#{port}"
      w.interval = 30 # seconds default
      w.start = "mongrel_rails cluster::start --only #{port} \
        -C #{RAILS_ROOT}/config/mongrel_production.yml"
      w.stop = "mongrel_rails cluster::stop --only #{port} \
        -C #{RAILS_ROOT}/config/mongrel_production.yml"
      w.grace = 10 # seconds
      
      pid_file = File.join(RAILS_ROOT, "log/mongrel.#{port}.pid")
      
      w.behavior(:clean_pid_file) do |b|
        b.pid_file = pid_file
      end

      w.start_if do |start|
        start.condition(:process_running) do |c|
          c.interval = 5 # seconds
          c.running = false
          c.pid_file = pid_file
        end
      end
      
      w.restart_if do |restart|
        restart.condition(:memory_usage) do |c|
          c.pid_file = pid_file
          c.above = (150 * 1024) # 150mb
          c.times = [3, 5] # 3 out of 5 intervals
        end
      
        restart.condition(:cpu_usage) do |c|
          c.pid_file = pid_file
          c.above = 50 # percent
          c.times = 5
        end
      end
    end
  end
end
