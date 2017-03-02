require 'action_view/log_subscriber'
require 'action_controller/log_subscriber'
require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/string/inflections'
require 'active_support/ordered_options'
require 'restash_rails/rails_ext/rack/logger'

module RestashRails
  module LogsUnsubscriber
    def disable_additional_logs
      disable_rack_cache_verbose_output(Rails.application) if defined?(Rails)
      ::ActiveSupport::LogSubscriber.log_subscribers.each do |subscriber|
        case subscriber.class.name
          when 'ActionView::LogSubscriber'
            unsubscribe(:action_view, subscriber)
          when 'ActionController::LogSubscriber'
            unsubscribe(:action_controller, subscriber)
          when 'ActionMailer::LogSubscriber'
            unsubscribe(:action_mailer, subscriber)
          when 'ActiveRecord::LogSubscriber'
            unsubscribe(:active_record, subscriber)
        end
      end
    end

    private

    def unsubscribe(component, subscriber)
      events = subscriber.public_methods(false).reject { |method| method.to_s == 'call' }
      events.each do |event|
        ::ActiveSupport::Notifications.notifier.listeners_for("#{event}.#{component}").each do |listener|
          if listener.instance_variable_get('@delegate') == subscriber
            ::ActiveSupport::Notifications.unsubscribe listener
          end
        end
      end
    end

    def rack_cache_hashlike?(app)
      app.config.action_dispatch.rack_cache && app.config.action_dispatch.rack_cache.respond_to?(:[]=)
    end

    def disable_rack_cache_verbose_output(app)
      app.config.action_dispatch.rack_cache[:verbose] = false if rack_cache_hashlike?(app)
    end
  end
end
