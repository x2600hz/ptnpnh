require 'yaml'
require 'singleton'
require_relative './attackers/porno_attacker'
require_relative './attackers/mailman_attacker'
require_relative './attackers/educator_attacker'
require_relative './stats'
require_relative './config'

# The coordinator for threads. Creates threads and coordinates them
class Swarm
  include Singleton
  attr_reader :threads
  COORDINATOR_LOOP_INTERVAL = 1
  MAXIMUM_DOWNTIME_BEFORE_NEW_TARGET_SECONDS = 30

  def begin_assault
    spawn_threads
    start_coordinator_loop
  end

  # Returns the class responsible for attacking in the specified mode
  def attacker_klass
    case Config.instance.mode
    when :http
      PornoAttacker
    when :smtp
      MailManAttacker
    when :smtp_educator
      EducatorAttacker
    end
  end

  private

  def start_coordinator_loop
    while true
      Stats.instance.display_update

      # Re-evaluate the target
      if Stats.instance.target_duration > MAXIMUM_DOWNTIME_BEFORE_NEW_TARGET_SECONDS && Stats.instance.throughput == 0
        attacker_klass.target_finder.select_new_target
      end

      sleep COORDINATOR_LOOP_INTERVAL
    end
  end

  def spawn_threads
    @threads = []
    (0...Config.instance.number_of_threads).each do |i|
      thread = Thread.new { attacker_klass.new.bombs_away }
      thread[:id] = i
      @threads << thread
      Stats.instance.display_update # For showing what's going on as they're spawning
      sleep 1 # Stagnate the starting of threads
    end
  end
end
