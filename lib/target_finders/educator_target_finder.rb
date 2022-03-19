require_relative './base_target_finder'
require_relative '../config'

class EducatorTargetFinder < BaseTargetFinder
  def initialize
    # Does not support single target mode
    @targets = YAML.load(File.read('./data/email/fuckers.yaml'))
    super
  end

  def target
    # Always pick a different one, do not fixate
    @targets.sample
  end
end
