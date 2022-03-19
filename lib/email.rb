require 'net/smtp'
require 'securerandom'
require 'singleton'
require 'base64'
require_relative './mx'

class Email
  include Singleton
  SMTP_OPEN_TIMEOUT = 1
  SMTP_READ_TIMEOUT = 1

  def initialize
    @sender_names ||= YAML.load(File.read("./data/oligarchs.yaml"))
    # Cache MX lookups - we don't want to hammer the DNS server
    @mx_records = Hash.new do |hash, domain|
      hash[domain] = Domain.new.mxers(domain)
    end
  end

  def send_mail(receiver_email)
    handle, domain = receiver_email.split('@')
    mx_records = @mx_records[domain]
    random_mail_server_record = mx_records.sample

    return if random_mail_server_record.nil? # If the lookup failed we stop here

    mailserver = random_mail_server_record.first
    sender_name = @sender_names.sample
    sender_email = sender_name_to_email(sender_name, domain)

    Net::SMTP.start(mailserver, 25) do |smtp|
      # TODO: Timeouts are not being respected
      smtp.open_timeout = SMTP_OPEN_TIMEOUT
      smtp.read_timeout = SMTP_READ_TIMEOUT
      smtp.send_message(
        message_body(sender_name, sender_email, handle, receiver_email, domain),
        sender_email,
        receiver_email
      )
      smtp.finish
    end

    Stats.instance.increment_count_success
  rescue EOFError
    Stats.instance.increment_count_error
  rescue Net::SMTPFatalError
    Stats.instance.increment_count_error
  rescue Net::SMTPSyntaxError
    Stats.instance.increment_count_error
  rescue OpenSSL::SSL::SSLError
    Stats.instance.increment_count_error
  rescue Net::SMTPServerBusy
    Stats.instance.increment_count_error
  rescue Net::OpenTimeout
    Stats.instance.increment_count_incomplete
  rescue Net::ReadTimeout
    Stats.instance.increment_count_incomplete
  rescue Errno::ECONNREFUSED
    Stats.instance.increment_count_incomplete
  end

  def sender_name_to_email(name, domain)
    "#{name.downcase.sub(' ','.')}@#{domain}"
  end

  def message_body(sender_name, sender_email, target_name, target_email, domain)
    # This sends a general anti-war message. The message body is taken from http://1920.in/ and the subject is equivalent to PTNPNH. They are encoded in Base64 to make the repository less indexable if the recipient searches the message online.
    subject = Base64.decode64('0J/Rg8yB0YLQuNC9IC0g0YXRg9C50LvQvsyB').force_encoding('utf-8')
    message = Base64.decode64('0KPQstCw0LbQsNC10LzRi9C1INGA0L7RgdGB0LjRj9C90LUsINCy0LDRiNC4INCh0JzQmCDQv9C+0LTQstC10YDQs9Cw0Y7RgtGB0Y8g0YbQtdC90LfRg9GA0LUuINCa0YDQtdC80LvRjCDQu9C20LXRgi4g0KLRi9GB0Y/Rh9C4INCy0LDRiNC40YUg0YHQvtC70LTQsNGCINC4INGD0LrRgNCw0LjQvdGB0LrQuNGFINCx0YDQsNGC0YzQtdCyINCz0LjQsdC90YPRgiDQvdCwINCj0LrRgNCw0LjQvdC1LiDQo9C30L3QsNC50YLQtSDQv9GA0LDQstC00YMg0LIg0YHQstC+0LHQvtC00L3QvtC8INCY0L3RgtC10YDQvdC10YLQtSDQuCDQsiDQv9GA0LjQu9C+0LbQtdC90LjQuCBUZWxlZ3JhbS4g0JLRgNC10LzRjyDRgdCy0LXRgNCz0L3Rg9GC0Ywg0LTQuNC60YLQsNGC0L7RgNCwINCf0YPRgtC40L3QsCE=').force_encoding('utf-8')

    %{From: #{sender_name} <#{sender_email}>
To: #{target_name} <#{target_email}>
Subject: #{subject}
Date: #{Time.now.to_s}
Message-Id: <#{SecureRandom.uuid}@#{domain}>

#{message}
    }
  end
end
