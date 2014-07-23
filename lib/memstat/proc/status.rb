module Memstat
  module Proc
    class Status < Base
      FIELDS = %w[peak size lck pin hwm rss data stk exe lib pte swap]
      attr_accessor *FIELDS

      def initialize(options = {})
        super
        @path ||= "/proc/#{@pid}/status"

        run
      end

      def run
        @lines = File.readlines(@path).map(&:strip)
        @hash = {}

        @lines.each do |line|
          match = line.match(/(\w+):(.*)/)
          key = match[1]
          value = match[2]

          @hash[key] = value

          if match = key.match(/Vm(\w+)/)
            field = match[1].downcase
            if respond_to? "#{field}="
              send("#{field}=", Integer(value.strip.split.first) * 1024)
            end
          end
        end
      end
    end
  end
end
