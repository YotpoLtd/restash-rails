module Resque
  module Logging
    def self.log(severity, message)
      RestashRails.logger.send(severity, { resque_message: message, tag: :resque })
    end
  end
end