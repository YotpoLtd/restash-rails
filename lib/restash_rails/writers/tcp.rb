module RestashRails
  module Writer
    class Tcp < Base
      attr_accessor :logstash_host, :logstash_port, :timeout_options

      def initialize(configs)
        @logstash_host = configs[:host] || '127.0.0.1' #logstash host
        @logstash_port = configs[:port].to_i || 5960 #logstash port
        if configs[:timeout_options].present?
          configs[:timeout_options].each{ |k,v| configs[:timeout_options][k] = v.to_f }
          @timeout_options = configs[:timeout_options]
        else
          @timeout_options = { connect_timeout: DEFAULT_TIMEOUT, write_timeout: DEFAULT_TIMEOUT, read_timeout: DEFAULT_TIMEOUT }
        end
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
    end
  end
end