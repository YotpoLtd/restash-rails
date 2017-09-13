module Resque
  module Plugins
    module RestashLogger
      # Executed on the Resque worker
      def before_perform_logstash_logger(*args)
        @resque_job_uuid = SecureRandom.uuid
        @job_start_time = Time.now
        log 'Executing', args
      end

      def after_perform_logstash_logger(*args)
        @job_end_time = Time.now
        log 'Finished', args
      end

      def on_failure_logstash_logger(*args)
        @job_end_time = Time.now
        log 'Failed', args, :error
      end

      # Executed on the enqueueing instance
      def after_enqueue_logstash_logger(*args)
        log 'Enqueued', args
      end

      def after_schedule_send_monitor_data(*args)
        log 'Scheduled', args
      end

      def log(log_message, args, severity = :info)
        extra_data = args.is_a?(Array) ? args.last : args
        log_arguments = { log_message: log_message, extra_data: extra_data, class: self.name, log_tag: :resque_hooks }
        if args.is_a?(Array) && args.first.is_a?(Exception)
          exception = args.first
          log_arguments[:exception] = { class: exception.class.to_s, message: exception.message.to_s, backtrace: exception.backtrace }
        end
        log_arguments[:exec_run_time] = @job_end_time - @job_start_time if @job_start_time.present? && @job_end_time.present?
        log_arguments[:resque_job_uuid] = @resque_job_uuid if @resque_job_uuid.present?
        Rails.logger.send(severity, log_arguments)
      end
    end
  end
end
