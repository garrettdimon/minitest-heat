# frozen_string_literal: true

require 'test_helper'

class Minitest::Heat::BacktraceTest < Minitest::Test
  def setup
    project_dir = Dir.pwd
    gem_dir = Gem.dir


    @source_code_line = "#{project_dir}/lib/minitest/heat.rb:29:in `method_name'"
    @test_line = "#{project_dir}/test/minitest/heat_test.rb:27:in `other_method_name'"

    @raw_backtrace = [
      @source_code_line,
      @test_line,
      "#{gem_dir}/gems/minitest-5.14.4/lib/minitest/test.rb:98:in `block (3 levels) in run'",
      "#{gem_dir}/gems/minitest-5.14.4/lib/minitest/test.rb:195:in `capture_exceptions'",
      "#{gem_dir}/gems/minitest-5.14.4/lib/minitest/test.rb:95:in `block (2 levels) in run'"
    ]
    @key_file = @raw_backtrace.first.split(':').first

    @backtrace = Minitest::Heat::Backtrace.new(@raw_backtrace)
  end

  def test_fails_gracefully_when_it_cannot_read_a_file
    @raw_backtrace = ["/file/does/not/exist.rb"]
    @backtrace = Minitest::Heat::Backtrace.new(@raw_backtrace)

    refute_nil @backtrace.parsed_lines.first
  end

  def test_parsing_backtrace_entries
    backtrace_entry_string = "/dirname/basename.rb:5:in `<main>'"
    entry = Minitest::Heat::Backtrace::Entry.new(backtrace_entry_string)

    assert_equal '/dirname/basename.rb', entry.pathname.to_s
    assert_equal 5, entry.line_number
    assert_equal '<main>', entry.container
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
    assert_equal @backtrace.recently_modified_lines.first, @backtrace.freshest_project_location
  end

  def test_identifying_last_run_test_line
    refute_equal @backtrace.project_lines, @backtrace.test_lines

    assert_equal @backtrace.project_lines[1], @backtrace.final_test_location
  end
end
