module RestashRails
  module Formatter
    class Default
      def format_message(message = nil)
        log_message = {}
        message.is_a?(Hash) ? log_message.merge!(message) : log_message[:log_message] = message
        return log_message
      rescue => e
        {
            severity: 'ERROR',
            log_message: 'Failed to format logstash message',
            exception: { class: e.class, message: e.message },
            logstash_message: log_message,
            log_tag: :logstash_formatter_failed
        }
      end
    end
  end
end