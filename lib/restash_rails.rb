require 'restash_rails/rails_ext/action_dispatch/middleware/debug_exceptions'
require 'rack/utils'
require 'restash_rails/version'
require 'restash_rails/logger'
require 'restash_rails/logs_unsubscriber'
require 'restash_rails/log_subscriber/log_subscriber'
require 'restash_rails/formatters/default'
require 'restash_rails/railtie' if defined?(Rails::Railtie)
require 'restash_rails/rails_ext/core_ext/hash'

module RestashRails
  mattr_accessor :logger
  extend RestashRails::LogSubscriber
  extend RestashRails::LogsUnsubscriber

  class << self
    def setup(configs = {})
      return unless configs.present? && configs.is_a?(Hash)
      configs = configs.with_indifferent_access
      return unless is_true?(configs[:enabled])
      subscribe_logs(configs)
      disable_additional_logs unless configs[:additional_log] == true
      add_exception_statuses(configs[:exception_statuses] || [])
      @@logger = RestashRails::Logger.new(configs)
      @@logger
    end

    private

    # exception_statuses has to be an array of hashes.
    # Each hash has to contain status and types.
    # Types is an array of Exception classes
    # Example:
    #     error_401 = {:status => 401, :types => [Exceptions::AccessDenied, Exceptions::MyException]}
    #     error_422 = {:status => 422, :types => [Exceptions::InvalidParams]}
    #     exception_statuses = [error_401, error_422]

    def add_exception_statuses(exception_statuses = [])
      return unless exception_statuses.is_a?(Array) || exception_statuses.size > 0
      exception_statuses.each do |error|
        next unless error.is_a?(Hash)
        error = error.with_indifferent_access
        next unless error[:status].present? || (error[:types].present? && error[:types].is_a?(Array))
        status_symbol = ::Rack::Utils::HTTP_STATUS_CODES[error[:status].to_i].parameterize.underscore.to_sym
        existing_exceptions = ::ActionDispatch::ExceptionWrapper.rescue_responses.keys
        (error[:types].map(&:to_s) - existing_exceptions).each do |exceptions_class|
          ::ActionDispatch::ExceptionWrapper.rescue_responses.merge!({ exceptions_class => status_symbol })
        end
      end
    end
  end
end
