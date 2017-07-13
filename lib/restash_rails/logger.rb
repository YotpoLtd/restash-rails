require 'tcp_timeout'

module RestashRails
  class Logger
    include ::Logger::Severity
    attr_accessor :app_name, :level, :outputter, :formatter, :writer
    DEFAULT_TIMEOUT = 0.010

    def initialize(configs)
      self.level = configs[:level] || 'DEBUG'
      @logstash_host = configs[:host] || '127.0.0.1' #logstash host
      @logstash_port = configs[:port].to_i || 5960 #logstash port
      @app_name = configs[:app_name] || ENV['APP_NAME'] || Rails.application.class.name
      #TCP connection timeouts in milliseconds
      if configs[:timeout_options].present?
        configs[:timeout_options].each{ |k,v| configs[:timeout_options][k] = v.to_f }
        @timeout_options = configs[:timeout_options]
      else
        @timeout_options = { connect_timeout: DEFAULT_TIMEOUT, write_timeout: DEFAULT_TIMEOUT, read_timeout: DEFAULT_TIMEOUT }
      end
      set_formatter(configs)
      set_writer(configs)
    end

    ::Logger::Severity.constants.each do |severity|
      class_eval <<-METHOD, __FILE__, __LINE__ + 1

            def #{severity.downcase}?                # def debug?
              log_severity_allowed?(#{severity})     #   log_severity_allowed?(DEBUG)
            end                                      # end

            def #{severity.downcase}(message = nil)     # def debug(message = nil)
              log('#{severity.upcase}', message)        #   log('DEBUG', message)
            end                                         # end
      METHOD
    end

    def level=(level)
      return @level if @level.present?
      if level.is_a?(Integer)
        ::Logger::Severity.constants.each { |severity|
          return @level = severity if level == severity
        }
        raise "Log level #{level} not recognised"
      else
        desired_level = level.to_s.upcase
        raise "Log level #{level} not recognised" unless self.class.constants.include?(desired_level.to_sym)
        return  @level = class_eval(desired_level)
      end
    end
    
    private

    def set_formatter(configs)
      @formatter = ("Writer::#{configs[:formatter].to_s.capitalize}".safe_constantize || Formatter::Default).new(configs)
    rescue
      @formatter = Formatter::Default.new(configs)
    end

    def set_writer(configs)
      @writer = ("Writer::#{configs[:writer].to_s.capitalize}".safe_constantize || Writer::Tcp).new(configs)
    rescue
      @writer = Writer::Tcp.new(configs)
    end

    def log(severity, message = nil)
      severity_value = class_eval(severity.to_s.upcase)
      return unless log_severity_allowed?(severity_value)
      log_message = {}
      log_message[:severity] = severity
      log_message[:app_name] = app_name
      log_message[:rails_env] = environment
      log_message.merge!(formatter.format_message(message))
      log_message = log_message.with_indifferent_access
      log_message[:log_tag] ||= :custom
      write(log_message)
    end

    def log_severity_allowed?(severity)
      return false unless severity.is_a?(Integer)
      severity >= level
    end

    def write(data)
      json_data = data.to_json
      sock = ::TCPTimeout::TCPSocket.new(logstash_host, logstash_port, timeout_options)
      sock.write(json_data)
      sock.close
    rescue => e
      failures_logger = ::Logger.new(STDOUT)
      failures_logger.error({ status: "Failed to write data to #{logstash_host}:#{logstash_port}",  exception: e, data: data })
    end

    def environment
      (defined?(ENV['RAILS_ENV']) && ENV['RAILS_ENV']) ||
          (defined?(Rails.env) && Rails.env) ||
          (defined?(ENV['RACK_ENV']) && ENV['RACK_ENV']) ||
          :unknown
    end
  end
end