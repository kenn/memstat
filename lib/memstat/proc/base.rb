module Memstat
  module Proc
    class Base
      attr_accessor :pid, :path

      def initialize(options = {})
        raise Error.new('path or pid must be given') unless options[:path] || options[:pid]
        @pid  = options[:pid]
        @path = options[:path]
      end

      def pid?
        !!@pid
      end
    end
  end
end
