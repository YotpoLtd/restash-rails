module ActionController
  module Instrumentation
    def process_action(*args)
      raw_payload = {
          controller:  self.class.name,
          action:  self.action_name,
          params:  request.filtered_parameters,
          format:  request.format.try(:ref),
          method:  request.method,
          path:  (request.fullpath rescue 'unknown'),
          request_id:  (env['action_dispatch.request_id'] rescue 'not_defined')
      }
      ActiveSupport::Notifications.instrument('start_processing.action_controller', raw_payload.dup)

      ActiveSupport::Notifications.instrument('process_action.action_controller', raw_payload) do |payload|
        begin
          result = super
          payload[:status] = response.status
          result
        ensure
          append_info_to_payload(payload)
        end
       end
    end
  end
end