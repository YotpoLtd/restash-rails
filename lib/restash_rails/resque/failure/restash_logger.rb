module Resque
  module Failure
    class RestashLogger < Resque::Failure::Base
      def save
        begin
          message = {
              exception: {
                  class: exception.class.to_s,
                  message: exception.message.to_s,
                  backtrace: exception.backtrace
              },
              worker: worker.to_s,
              queue: queue,
              extra_data: payload,
              log_tag: :resque_failure
          }
          ::Rails.logger.error(message)
        rescue => e
          puts "Failed to send rescue_failure log: #{e.message}\n#{e.backtrace}"
        end
      end
    end
  end
end