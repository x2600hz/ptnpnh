require_relative '../email'
require_relative './base_attacker'
require_relative '../target_finders/smtp_target_finder'

class MailManAttacker < BaseAttacker
  def self.target_finder
    SmtpTargetFinder.instance
  end

  def perform_single_request
    domain = MailManAttacker.target_finder.target['domain']
    # New specific handle under that mail server each time
    handle = MailManAttacker.target_finder.target['handles'].sample
    receiver_email = "#{handle}@#{domain}"
    Thread.current[:target] = receiver_email
    Email.instance.send_mail(receiver_email)
  end
end
