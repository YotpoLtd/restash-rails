require 'action_view/log_subscriber'

module RestashRails
  module LogSubscriber
    class ActionView < ::ActionView::LogSubscriber
      def render_template(event)
        ::RestashRails.logger.info(generate_message(event))
      end
      alias :render_partial :render_template
      alias :render_collection :render_template

      private

      def generate_message(event)
        message = {
            duration: event.duration.round(2),
            identifier: from_rails_root(event.payload[:identifier]),
            log_tag: :action_view
        }
        message.merge!(layout: from_rails_root(event.payload[:layout])) unless event.payload[:layout].nil?
        return message
      end
    end
  end
end