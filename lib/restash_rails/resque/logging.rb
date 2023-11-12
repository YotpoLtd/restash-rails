module Resque
  module Logging
    def self.log(severity, message)
      min_severity = ENV['RESTASH_RAILS_RESQUE_MIN_LOG_LEVEL'] || 'INFO'
      return unless RestashRails.logger.log_level_allowed?(severity, min_severity)
      RestashRails.logger.send(severity, { resque_message: message, log_tag: :resque })
    end
  end
end
