require 'action_dispatch/middleware/debug_exceptions'

module ActionDispatch
  class DebugExceptions
    alias_method :default_log_error, :log_error
    def log_error(env, wrapper)
      exception = wrapper.exception
      if exception.is_a?(ActionController::RoutingError)
        message = {
            request_method: env['REQUEST_METHOD'],
            request_path: env['REQUEST_PATH'],
            response_code: wrapper.status_code,
            log_tag: :action_controller,
            exception: { class: exception.class.name, message: exception.message }
        }
        ::RestashRails.logger.warn(message)
      else
        default_log_error env, wrapper
      end
    rescue
      default_log_error env, wrapper
    end
  end
end
