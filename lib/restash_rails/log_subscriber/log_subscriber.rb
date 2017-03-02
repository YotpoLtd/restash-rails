require 'restash_rails/log_subscriber/subscribers/active_record'
require 'restash_rails/log_subscriber/subscribers/active_support'
require 'restash_rails/log_subscriber/subscribers/action_view'
require 'restash_rails/log_subscriber/subscribers/action_mailer'

module RestashRails
  module LogSubscriber
    def subscribe_logs(configs)
      RestashRails::LogSubscriber::ActiveSupport.attach_to :action_controller
      RestashRails::LogSubscriber::ActiveRecord.attach_to :active_record
      RestashRails::LogSubscriber::ActionView.attach_to :action_view
      RestashRails::LogSubscriber::ActionMailer.attach_to :action_mailer
      require 'restash_rails/resque/logging' if is_true?(configs[:resque_log])
      if is_true?(configs[:cache_log])
        require 'restash_rails/log_subscriber/subscribers/cache'
        RestashRails::LogSubscriber::Cache.attach_to :active_support
      end
    end

    def is_true?(variable)
      (variable.present? && (variable == true || variable == 'true'))
    end
  end
end