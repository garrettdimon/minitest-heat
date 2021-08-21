# frozen_string_literal: true

require 'test_helper'

class Minitest::Heat::BacktraceTest < Minitest::Test
  def setup
    @raw_backtrace = [
      "#{Dir.pwd}/lib/minitest/heat.rb:29:in `method_name'",
      "#{Dir.pwd}/test/minitest/heat_test.rb:27:in `other_method_name'",
      "#{Gem.dir}/gems/minitest-5.14.4/lib/minitest/test.rb:98:in `block (3 levels) in run'",
      "#{Gem.dir}/gems/minitest-5.14.4/lib/minitest/test.rb:195:in `capture_exceptions'",
      "#{Gem.dir}/gems/minitest-5.14.4/lib/minitest/test.rb:95:in `block (2 levels) in run'"
    ]
    @key_file = @raw_backtrace.first.split(':').first

    @backtrace = Minitest::Heat::Backtrace.new(@raw_backtrace)
  end

  def test_parsing
    parsed_backtrace = Minitest::Heat::Backtrace::Line.new(
      path: "#{Dir.pwd}/lib/minitest",
      file: 'heat.rb',
      number: '29',
      container: 'method_name',
      mtime: Pathname.new(@key_file).mtime
    )

    assert_equal parsed_backtrace, @backtrace.parsed.first
    assert_equal @backtrace.parsed.first, @backtrace.final_location
  end

  def test_keeping_only_project_lines
    refute_equal @backtrace.parsed, @backtrace.project
    assert_equal @backtrace.parsed.first, @backtrace.project.first
    refute_equal @backtrace.parsed.last, @backtrace.project.last
    assert_equal @backtrace.project.first, @backtrace.final_project_location
  end

  def test_sorting_by_modified_time
    test_file_location = File.expand_path(File.dirname(__FILE__))
    pathname = Pathname.new(test_file_location)
    pathname.utime(Time.now, Time.now)

    refute_equal @backtrace.project.reverse, @backtrace.recently_modified
    assert_equal @backtrace.recently_modified.first, @backtrace.freshest_project_location
  end

  def test_identifying_last_run_test_line
    refute_equal @backtrace.project, @backtrace.tests

    assert_equal @backtrace.project[1], @backtrace.final_test_location
  end
end
