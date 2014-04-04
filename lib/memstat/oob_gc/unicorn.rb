module Memstat
  module OobGC
    module Unicorn
      def self.new(app, threshold = (1024**3))
        self.const_set :OOBGC_THRESHOLD, threshold
        app # pretend to be Rack middleware since it was in the past
      end

      def process_client(client)
        super(client) # Unicorn::HttpServer#process_client
        status = Memstat::Proc::Status.new(:pid => Process.pid)

        if status.rss > OOBGC_THRESHOLD
          GC.start
        end
      end
    end
  end
end
