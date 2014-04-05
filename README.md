# Memstat: Fast memory statistics & better out-of-band GC

[![Build Status](https://secure.travis-ci.org/kenn/memstat.png)](http://travis-ci.org/kenn/memstat)

Ruby 2.1 introduced generational garbage collection. It is a major improvement in terms of shorter GC pauses and overall higher throughput, but that comes with a [drawback of potential memory bloat](http://www.omniref.com/blog/blog/2014/03/27/ruby-garbage-collection-still-not-ready-for-production/).

You can mitigate the bloat by manually running `GC.start`, but like Unicorn's out-of-band GC, doing it after every request can seriously hurt the performance. You want to run `GC.start` only when the process gets larger than X MB.

memstat offers a fast way to retrieve the memory usage of the current process, by providing direct access to `/proc/[pid]/status` and `/proc/[pid]/smaps`.

If you've ever called the `ps -o rss` command from inside a Ruby process to capture real memory usage, chances are, you've already learned that it is very slow.

That's because shelling out `ps` creates an entire copy of the ruby process - typically 70-150MB for a Rails app - then wipe out those memory with the executable of `ps`. Even with copy-on-write and POSIX-spawn optimization, you can't beat the speed of directly reading statistics from memory that is maintained by the kernel.

For a typical Rails app, memstat is 130 times faster than `ps -o rss`:

```ruby
Benchmark.bm(10) do |x|
  x.report("ps:")       { 100.times.each { `ps -o rss -p #{Process.pid}`.strip.to_i } }
  x.report("memstat:")  { 100.times.each { Memstat::Proc::Status.new(:pid => Process.pid).rss } }
end

                 user     system      total        real
ps:          0.110000   4.280000   6.260000 (  6.302661)
memstat:     0.040000   0.000000   0.040000 (  0.048166)
```

Tested on [Linode](https://www.linode.com) with a Rails app of 140MB memory usage.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'memstat'
```

Or install it yourself as:

```sh
$ gem install memstat
```

## Usage

Check the memory usage, and run GC if it's too big. Note that current version only supports Linux.

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

Other methods are:

```ruby
status.peak   # Peak VM size
status.size   # Current VM size
status.lck    # mlock-ed memory size (unswappable)
status.pin    # pinned memory size (unswappable and fixed physical address)
status.hwm    # Peak physical memory size
status.rss    # Current physical memory size
status.data   # Data area size
status.stk    # Stack size
status.exe    # Text (executable) size
status.lib    # Loaded library size
status.pte    # Page table size
status.swap   # Swap size
```

See [details](http://ewx.livejournal.com/579283.html) for each item.

## Command Line

memstat also comes with a command line utility to report detailed memory statistics by aggregating `/proc/[pid]/smaps`.

This is useful to examine the effectiveness of copy-on-write for forking servers like Unicorn.

Usage:

```sh
$ memstat smaps [PID]
```

will give you the following result:

```sh
Process:             13405
Command Line:        unicorn master -D -E staging -c /path/to/current/config/unicorn.rb
Memory Summary:
  size                      274,852 kB
  rss                       131,020 kB
  pss                        66,519 kB
  shared_clean                8,408 kB
  shared_dirty               95,128 kB
  private_clean                   8 kB
  private_dirty              27,476 kB
  swap                            0 kB
```

In this case, 103,536 kB out of 131,020 kB is shared, which means 79% of its memory is shared with worker processes.

For more details, [read this gist](https://gist.github.com/kenn/5105175).

## Changelog

### 0.1.0, release 2014-04-03
* Initial release
