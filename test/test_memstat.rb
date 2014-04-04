require 'memstat'
require 'minitest/autorun'
require 'benchmark'

class TestCli < Minitest::Test
  SMAPS_PATH = File.expand_path('../../test/files/smaps.txt', __FILE__)
  STATUS_PATH = File.expand_path('../../test/files/status.txt', __FILE__)

  def test_print
    smaps = Memstat::Proc::Smaps.new(:path => SMAPS_PATH)
    puts smaps.print
    STDOUT.flush
  end

  def test_smaps
    smaps = Memstat::Proc::Smaps.new(:path => SMAPS_PATH)

    assert_equal smaps.size,          277760  * 1024
    assert_equal smaps.rss,           131032  * 1024
    assert_equal smaps.pss,           75944   * 1024
    assert_equal smaps.shared_clean,  8504    * 1024
    assert_equal smaps.shared_dirty,  53716   * 1024
    assert_equal smaps.private_clean, 4       * 1024
    assert_equal smaps.private_dirty, 68808   * 1024
    assert_equal smaps.swap,          0       * 1024
  end

  def test_status
    status = Memstat::Proc::Status.new(:path => STATUS_PATH)

    assert_equal status.peak, 277756  * 1024
    assert_equal status.size, 277756  * 1024
    assert_equal status.lck,  0       * 1024
    assert_equal status.pin,  0       * 1024
    assert_equal status.hwm,  131044  * 1024
    assert_equal status.rss,  131044  * 1024
    assert_equal status.data, 133064  * 1024
    assert_equal status.stk,  136     * 1024
    assert_equal status.exe,  4       * 1024
    assert_equal status.lib,  21524   * 1024
    assert_equal status.pte,  540     * 1024
    assert_equal status.swap, 0       * 1024
  end

  def test_benchmark
    n = 100
    Benchmark.bm(10) do |x|
      x.report("ps:")       { n.times.each { `ps -o rss -p #{Process.pid}`.strip.split.last.to_i } }
      x.report("memstat:")  { n.times.each { Memstat::Proc::Status.new(:pid => Process.pid).rss } }
    end
  end
end
