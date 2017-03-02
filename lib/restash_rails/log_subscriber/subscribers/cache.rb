require 'restash_rails/rails_ext/active_support/cache/store'
require 'active_support/log_subscriber'

module RestashRails
  module LogSubscriber
    class Cache < ::ActiveSupport::LogSubscriber
      def cache_read(event)
        log(event)
      end
      def cache_delete_tag_tree(event)
        log(event)
      end
      def cache_delete_wiled_card(event)
        log(event)
      end
      def cache_write_value(event)
        log(event)
      end
      def cache_write_tags(event)
        log(event)
      end
      def cache_write(event)
        log(event)
      end
      def cache_fetch(event)
        log(event)
      end
      def cache_delete_tag_keys(event)
        log(event)
      end
      def cache_delete(event)
        log(event)
      end

      def logger
        ::RestashRails.logger
      end

      private

      def log(event)
        message = generate_message(event)
        (duration > 100) ?
            logger.debug(message.merge({ execution: 'slow' })) :
            logger.debug(message)
      end

      def generate_message(event)
        payload = event.payload
        message = {
            name: event.name,
            duration: event.duration,
            cache_key: payload[:key],
            host: payload[:host],
            port: payload[:port],
            expire_in: payload[:expire_in],
            tag: :cache
        }
        message.merge(exception_formatter(payload))
      end

      def exception_formatter(payload)
        return {} if payload[:exception].nil?
        exception_class, message = payload[:exception]
        { exception_class: exception_class, message: message}
      end
    end
  end
end