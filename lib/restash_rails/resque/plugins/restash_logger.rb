module Resque
  module Plugins
    module RestashLogger
      # Executed on the Resque worker
      def before_perform_logstash_logger(*args)
        @resque_job_uuid = SecureRandom.uuid
        log 'Executing', args
      end

      def after_perform_logstash_logger(*args)
        log 'Finished', args
      end

      def on_failure_logstash_logger(*args)
        log 'Failed', args, :error
      end

      # Executed on the enqueueing instance
      def after_enqueue_logstash_logger(*args)
        log 'Enqueued', args
      end

      def after_schedule_send_monitor_data(*args)
        log 'Scheduled', args
      end

      def log(status, args, severity = :info)
        log_arguments = { status: status, extra_data: args, class: self.name, log_tag: :resque_hooks }
        if args.is_a?(Array) && args[0].is_a?(Exception)
          exception = args.shift
          log_arguments[:exception] = { class: exception.class, message: exception.message, backtrace: exception.backtrace }
        end
        log_arguments[:resque_job_uuid] = @resque_job_uuid if @resque_job_uuid.present?
        Rails.logger.send(severity, log_arguments)
      end
    end
  end
end
