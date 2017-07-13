module RestashRails
  module Writer
    class Stdout < Base
      def write(data)
        ::STDOUT.puts "\n" + data.to_json
      end
    end
  end
end