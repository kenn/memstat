# Memstat: Fast memory statistics & Better Out-of-band GC

Ruby 2.1 introduced generational garbage collection. It is a major improvement in terms of shorter GC pauses and overall higher throughput, but that comes with a [drawback of potential memory bloat](http://www.omniref.com/blog/blog/2014/03/27/ruby-garbage-collection-still-not-ready-for-production/).

You can mitigate the bloat by manually running `GC.start`, but like Unicorn's out-of-band GC, doing it after every request can seriously hurt the performance. You want to run `GC.start` only when the process gets larger than X MB.

memstat offers a fast way to retrieve the memory usage of the current process, by providing direct access to `/proc/[pid]/status` and `/proc/[pid]/smaps`.

If you've ever called the `ps -o rss` command from inside a Ruby process to capture real memory usage, chances are, you've already learned that it is very slow.

That's because shelling out `ps` creates an entire copy of the ruby process - typically 70-150MB for a Rails app - then wipe out those memory with the executable of `ps`. Even with copy-on-write and POSIX-spawn optimization, you can't beat the speed of directly reading statistics from memory that is maintained by the kernel.

With a minimal Ruby program, memstat is 10 times faster than `ps -o rss`. The speed diff only gets wider when your Ruby process is bigger.

```
                 user     system      total        real
ps:          0.010000   0.040000   0.160000 (  0.168328)
memstat:     0.020000   0.000000   0.020000 (  0.017127)
```

## Installation

Add this line to your application's Gemfile:

    gem 'memstat'

Or install it yourself as:

    $ gem install memstat

## Usage

```ruby
if Memstat.linux?
  status = Memstat::Proc::Status.new(pid: Process.pid)
  if status.rss > 150.megabytes
    GC.start
  end
end
```

For Unicorn, add these lines to your `config.ru` (should be added above loading environment) to check memory size on every request and run GC out-of-band:

```ruby
require 'memstat'

use Memstat::OobGC::Unicorn, 150*(1024**2)  # Invoke GC if the process is bigger than 150MB
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
