module ActiveSupport
  module Cache
    class Store
      alias default_instrument instrument
      def instrument(operation, key, options = nil)
        self.class.instrument = true
        default_instrument(operation, key, options, &Proc.new)
      end
    end
  end
end