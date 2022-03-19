class BaseAttacker
  NUMBER_OF_SECONDS_BETWEEN_REQUESTS = $LOW_INTENSITY ? 2 : 0.5

  def bombs_away
    while true
      perform_single_request
      sleep(NUMBER_OF_SECONDS_BETWEEN_REQUESTS)
    end
  end

  def perform_single_request
    raise 'Must be implemented in overriding class'
  end

  # Returns the appropriate instance of the target finder class
  def self.target_finder
    raise 'Must be implemented in overriding class'
  end
end
