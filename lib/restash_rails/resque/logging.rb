module Resque
  module Logging
    def self.log(severity, message)
      RestashRails.logger.send(severity, { resque_message: message, log_tag: :resque })
    end
  end
end