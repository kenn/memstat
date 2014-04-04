module Memstat
  module Proc
    class Smaps < Base
      FIELDS = %w[size rss pss shared_clean shared_dirty private_clean private_dirty swap]
      attr_accessor *FIELDS
      attr_accessor :lines, :items

      def initialize(options = {})
        super
        @path ||= "/proc/#{@pid}/smaps"

        FIELDS.each do |field|
          send("#{field}=", 0)
        end

        run
      end

      def run
        @lines = File.readlines(@path).map(&:strip)
        @items = []
        item = nil

        @lines.each.with_index do |line, index|
          case line
          when /[0-9a-f]+:[0-9a-f]+\s+/
            item = Item.new
            @items << item
            item.parse_first_line(line)
          when /\w+:\s+/
            item.parse_field_line(line)
          else
            raise Error.new("invalid format at line #{index + 1}: #{line}")
          end
        end

        @items.each do |item|
          FIELDS.each do |field|
            send "#{field}=", (send(field) + item.send(field))
          end
        end
      end

      def print
        @print ||= begin
          lines = []
          lines << "#{"Process:".ljust(20)} #{@pid || '[unspecified]'}"
          lines << "#{"Command Line:".ljust(20)} #{command || '[unspecified]'}"
          lines << "Memory Summary:"
          FIELDS.each do |field|
            lines << "  #{field.ljust(20)} #{number_with_delimiter(send(field)/1024).rjust(12)} kB"
          end
          lines.join("\n")
        end
      end

      def command
        return unless pid?
        commandline = File.read("/proc/#{@pid}/cmdline").split("\0")
        if commandline.first =~ /java$/ then
          loop { break if commandline.shift == "-jar" }
          return "[java] #{commandline.shift}"
        end
        return commandline.join(' ')
      end

      def number_with_delimiter(n)
        n.to_s.gsub(/(\d)(?=\d{3}+$)/, '\\1,')
      end


      #
      # Memstat::Proc::Smaps::Item
      #

      class Item
        attr_accessor *FIELDS

        attr_reader :address_start
        attr_reader :address_end
        attr_reader :perms
        attr_reader :offset
        attr_reader :device_major
        attr_reader :device_minor
        attr_reader :inode
        attr_reader :region

        def initialize
          FIELDS.each do |field|
            send("#{field}=", 0)
          end
        end

        def parse_first_line(line)
          parts = line.strip.split
          @address_start, @address_end = parts[0].split('-')
          @perms = parts[1]
          @offset = parts[2]
          @device_major, @device_minor = parts[3].split(':')
          @inode = parts[4]
          @region = parts[5] || 'anonymous'
        end

        def parse_field_line(line)
          parts = line.strip.split
          field = parts[0].downcase.sub(':','')
          return if field == 'vmflags'
          value = Integer(parts[1]) * 1024
          send("#{field}=", value) if respond_to? "#{field}="
        end
      end

    end
  end
end
