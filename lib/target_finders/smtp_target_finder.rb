require_relative './base_target_finder'
require_relative '../config'

class SmtpTargetFinder < BaseTargetFinder
  def initialize
    if Config.instance.is_single_target_mode?
      handle, domain = Config.instance.target.split('@')
      @target = { 'domain' => domain, 'handles' => [handle] }
    else
      @targets = YAML.load(File.read('./data/email/by_domain.yaml'))
    end
    super
  end

  def select_new_target
    super
    @handles_count = @target['handles'].count
  end

  def current_target_printable
    return Config.instance.target if Config.instance.is_single_target_mode?

    "#{@target['domain']} (#{@handles_count} users)"
  end
end
