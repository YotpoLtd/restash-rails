module RestashRails
  class TcpBufferedLogger

    def initialize(logstash_host, logstash_port, timeout_options, buffer_size_chars, buffer_flush_timeout_secs)
      @logstash_host = logstash_host
      @logstash_port = logstash_port
      @timeout_options = timeout_options
      @buffer_size_chars = buffer_size_chars
      @buffer_flush_timeout_secs = buffer_flush_timeout_secs
      @last_flush = Time.now
      @data_buffer = ''
    end

    def write(json_data)
      @data_buffer += json_data + "\n"
      seconds_since_last_flush = Time.now - @last_flush
      if @data_buffer.length > @buffer_size_chars || seconds_since_last_flush > @buffer_flush_timeout_secs.seconds
        puts("flushing logs: #{@data_buffer.length}, #{seconds_since_last_flush}")
        sock = ::TCPTimeout::TCPSocket.new(@logstash_host, @logstash_port, @timeout_options)
        sock.write(@data_buffer)
        @last_flush = Time.now
        @data_buffer = ''
        sock.close
      end
    end

  end
end
