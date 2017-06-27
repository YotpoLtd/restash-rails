require 'action_mailer/log_subscriber'

module RestashRails
  module LogSubscriber
    class ActionMailer < ::ActionMailer::LogSubscriber
      def deliver(event)
        ::RestashRails.logger.info(generate_message(event, 'deliver'))
      end

      private

      def generate_message(event, action)
        {
            to: event.payload[:to],
            duration: event.duration.round(2),
            action: action,
            log_tag: :action_mailer
        }
      end
    end
  end
end