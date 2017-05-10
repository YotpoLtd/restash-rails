require 'active_record/log_subscriber'

module RestashRails
  module LogSubscriber
    class ActiveRecord < ::ActiveRecord::LogSubscriber
      def sql(event)
        ::RestashRails.logger.debug(generate_message(event))
      end

      private

      def generate_message(event)
        {
            sql: event.payload[:sql].to_s,
            duration: event.duration.round(2),
            name: event.payload[:name],
            log_tag: :active_record
        }
      end
    end
  end
end