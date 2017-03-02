require 'rails/railtie'

module RestashRails
  class Railtie < ::Rails::Railtie
    config.restash_rails = ::ActiveSupport::OrderedOptions.new
    config.restash_rails.enabled = false
    initializer :restash, before: :initialize_logger do |app|
      app.config.restash_rails = app.config.restash_rails.deep_symbolize_keys
      app.config.logger = RestashRails.setup(app.config.restash_rails)
    end
  end
end