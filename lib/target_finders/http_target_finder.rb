require_relative './base_target_finder'

class HttpTargetFinder < BaseTargetFinder
  def initialize
    if Config.instance.is_single_target_mode?
      @target = Config.instance.target
    else
      @targets = YAML.load(File.read('./data/urls/shit_list.yaml'))
    end
    super
  end
end
