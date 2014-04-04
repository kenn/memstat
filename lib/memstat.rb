require 'thor'

module Memstat
  autoload :Cli,      'memstat/cli'
  autoload :Version,  'memstat/version'

  module OobGC
    autoload :Unicorn,  'memstat/oob_gc/unicorn'
  end

  module Proc
    autoload :Base,   'memstat/proc/base'
    autoload :Smaps,  'memstat/proc/smaps'
    autoload :Status, 'memstat/proc/status'
  end

  Error = Class.new(StandardError)

  def linux?
    RUBY_PLATFORM =~ /linux/
  end

  module_function :linux?
end
