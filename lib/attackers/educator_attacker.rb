require_relative '../email'
require_relative './base_attacker'
require_relative '../target_finders/educator_target_finder'

class EducatorAttacker < BaseAttacker
  def self.target_finder
    EducatorTargetFinder.instance
  end

  def perform_single_request
    target = EducatorAttacker.target_finder.target
    Thread.current[:target] = target
    Email.instance.send_mail(target)
  end
end
