require 'active_support/log_subscriber'
require 'restash_rails/rails_ext/action_pack/action_controller/metal/instrumentation'

module RestashRails
  module LogSubscriber
    class ActiveSupport < ::ActionController::LogSubscriber
      def process_action(event)
        log_message = generate_message(event)
        if log_message[:response_code] >= 500
          logger.error(log_message)
        elsif log_message[:response_code] >= 400
          logger.warn(log_message)
        else
          logger.info(log_message)
        end
      end

      def redirect_to(event)
        log_message = generate_message(event)
        logger.info (log_message)
      end

      def logger
        ::RestashRails.logger
      end

      private

      def exception_formatter(payload)
        return {} unless payload[:exception].present?
        if exception.is_a?(Array)
          exception_class, exception_message = payload[:exception]
          { class: exception_class, message: exception_message }
        else
          { exception_string: payload[:exception].to_s }
        end
      end


      def extract_status(payload)
        if (status = payload[:status])
          status.to_i
        elsif (error = payload[:exception])
          exception, message = error
          get_error_status_code(exception)
        else
          200
        end
      end

      def get_error_status_code(exception)
        status = ::ActionDispatch::ExceptionWrapper.rescue_responses[exception]
        ::Rack::Utils.status_code(status)
      end

      def generate_message(event)
        payload = event.payload
        excepted_params = %w(controller action format id)
        {
            controller: payload[:controller].to_s,
            action: payload[:action].to_s,
            request_method: payload[:method].to_s,
            uuid: payload[:request_id],
            response_code: extract_status(payload),
            path: payload[:path].to_s,
            format: payload[:format].to_s,
            request_params: (payload[:params].except(*excepted_params) rescue {}),
            duration: event.duration.to_f.round(2),
            redirect_to: payload[:location] || '',
            db_duration: ((payload[:db_runtime] * 100).round(2)/100.0 rescue 0.0),
            view_duration: ((payload[:view_runtime] * 100).round(2)/100.0 rescue 0.0),
            log_tag: :action_controller,
            exception: exception_formatter(payload)
        }
      end
    end
  end
end