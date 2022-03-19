require 'singleton'
require_relative './config'

class Stats
  include Singleton
  attr_reader :start_time_target

  UPDATE_INTERVAL_SECONDS = 0.5
  THROUGHPUT_INTERVAL_SECONDS = 10

  def initialize
    @start_time = Time.now.to_i
    @throughput_buffer = []
    reset_counters
    reset_target_duration
  end

  def display_update
    total_requests = @requests_success + @requests_error + @requests_incomplete

    if total_requests > 0
      percent_error = ((@requests_success + @requests_error) * 100 / total_requests).round(2)
    else
      percent_error = "-"
    end

    puts "\e[H\e[2J" # Reset the terminal so it doesn't spam
    puts %{
    ПТН ПНХ

    Слава Україні! Героям слава!

      Total running time: #{Time.now.to_i - @start_time} sec
      Number of threads operating: #{Config.instance.number_of_threads}

      Running time on target: #{target_duration} sec

      Total requests: #{total_requests}
      Hits% (errors + successes): #{percent_error}%
      Success count: #{@requests_success}
      Error count: #{@requests_error}
      Timeouts count: #{@requests_incomplete}
      Throughput (Requests per #{THROUGHPUT_INTERVAL_SECONDS} sec): #{throughput}

    }

    Swarm.instance.threads.each do |thread|
      puts "      Thread#{thread[:id]} -> #{thread[:target]}"
    end
  end

  def reset_counters
    @requests_success = 0
    @requests_error = 0
    @requests_incomplete = 0
  end

  def target_duration
    Time.now.to_i - @start_time_target
  end

  def reset_target_duration
    @start_time_target = Time.now.to_i
  end

  def increment_count_success
    @requests_success += 1
    log_throughput
  end

  def increment_count_error
    @requests_error += 1
    log_throughput
  end

  def increment_count_incomplete
    @requests_incomplete += 1
  end

  def throughput
    current_time = Time.now.to_i
    @throughput_buffer.select! { |t| t > (Time.now.to_i - THROUGHPUT_INTERVAL_SECONDS) }
    @throughput_buffer.count
  end

  private

  def log_throughput
    @throughput_buffer << Time.now.to_i
  end
end
