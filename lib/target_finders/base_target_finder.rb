require 'singleton'
require_relative '../config'

class BaseTargetFinder
  include Singleton

  def initialize
    select_new_target
  end

  def select_new_target
    return if Config.instance.is_single_target_mode?

    @target = @targets.sample
    Stats.instance.reset_target_duration
  end

  def current_target_printable
    @target
  end

  def target
    @target
  end
end
