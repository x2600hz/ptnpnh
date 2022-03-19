require 'singleton'
require 'etc'

class Config
  include Singleton
  attr_accessor :mode, :target

  def initialize
    @number_of_threads = Etc.nprocessors
  end

  def number_of_threads
    @number_of_threads
  end

  def number_of_threads=(value)
    if value < 1
      puts 'Number of threads must be at least 1'
      exit 1
    end

    @number_of_threads = value
  end

  def is_single_target_mode?
    !@target.nil?
  end
end
