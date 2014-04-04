module Memstat
  class Cli < Thor

    # Aggregate information from /proc/[pid]/smaps
    #
    # pss  - Roughly the amount of memory that is "really" being used by the pid
    # swap - Amount of swap this process is currently using
    # 
    desc 'smaps', 'Print useful information from /proc/[pid]/smaps'
    def smaps(pid)
      abort 'Error: unsupported OS' unless Memstat.linux?
      result = Memstat::Proc::Smaps.new(:pid => pid)
      puts result.print
    end
  end
end
