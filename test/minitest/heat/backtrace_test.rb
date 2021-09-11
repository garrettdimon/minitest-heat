# frozen_string_literal: true

require 'test_helper'

class Minitest::Heat::BacktraceTest < Minitest::Test
  def setup
    @source_code_line = "#{Dir.pwd}/lib/minitest/heat.rb:29:in `method_name'"
    @test_line = "#{Dir.pwd}/test/minitest/heat_test.rb:27:in `other_method_name'"

    @raw_backtrace = [
      @source_code_line,
      @test_line,
      "#{Gem.dir}/gems/minitest-5.14.4/lib/minitest/test.rb:98:in `block (3 levels) in run'",
      "#{Gem.dir}/gems/minitest-5.14.4/lib/minitest/test.rb:195:in `capture_exceptions'",
      "#{Gem.dir}/gems/minitest-5.14.4/lib/minitest/test.rb:95:in `block (2 levels) in run'"
    ]
    @key_file = @raw_backtrace.first.split(':').first

    @backtrace = Minitest::Heat::Backtrace.new(@raw_backtrace)
  end

  def test_parsing
    parsed_backtrace_line = Minitest::Heat::Backtrace::Line.new(
      path: "#{Dir.pwd}/lib/minitest",
      file: 'heat.rb',
      number: '29',
      container: 'method_name',
      mtime: Pathname.new(@key_file).mtime
    )

    assert_equal parsed_backtrace_line, @backtrace.parsed_lines.first
    assert_equal @backtrace.parsed_lines.first, @backtrace.final_location
  end

  def test_backtrace_line
    file = __FILE__.split('/').last
    path = __FILE__.delete_suffix("/#{file}")
    number = '29'
    container = 'method_name'
    mtime = Pathname.new(@key_file).mtime

    parsed_backtrace_line = Minitest::Heat::Backtrace::Line.new(
      path: path,
      file: file,
      number: number,
      container: container,
      mtime: mtime
    )

    assert_match(/test\/minitest\/heat\/backtrace_test\.rb\:29 in `method_name`/, parsed_backtrace_line.to_s)
    assert_match(/test\/minitest\/heat\/backtrace_test\.rb\:29/, parsed_backtrace_line.to_location)
    assert_match(/test\/minitest\/heat\/backtrace_test\.rb/, parsed_backtrace_line.to_file)
  end

  def test_keeping_only_project_lines
    refute_equal @backtrace.parsed_lines, @backtrace.project_lines
    assert_equal @backtrace.parsed_lines.first, @backtrace.project_lines.first
    refute_equal @backtrace.parsed_lines.last, @backtrace.project_lines.last
    assert_equal @backtrace.project_lines.first, @backtrace.final_project_location
  end

  def test_keeping_only_source_code_lines
    refute_equal @backtrace.parsed_lines, @backtrace.source_code_lines
    assert_equal @backtrace.parsed_lines.first, @backtrace.source_code_lines.first
    refute_equal @backtrace.parsed_lines.last, @backtrace.source_code_lines.last
    assert_equal @backtrace.project_lines.first, @backtrace.final_source_code_location
  end

  def test_sorting_by_modified_time
    test_file_location = File.expand_path(File.dirname(__FILE__))
    pathname = Pathname.new(test_file_location)
    pathname.utime(Time.now, Time.now)

    assert @backtrace.project_lines.size > 1
    refute_equal @backtrace.project_lines, @backtrace.recently_modified_lines
    assert_equal @backtrace.recently_modified_lines.first, @backtrace.freshest_project_location
  end

  def test_identifying_last_run_test_line
    refute_equal @backtrace.project_lines, @backtrace.test_lines

    assert_equal @backtrace.project_lines[1], @backtrace.final_test_location
  end
end
