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
    @raw_backtrace = ["/file/does/not/exist.rb:5:in `capture_exceptions'"]
    @backtrace = Minitest::Heat::Backtrace.new(@raw_backtrace)

    refute_nil @backtrace.parsed_entries.first
  end

  def test_keeping_only_project_entries
    refute_equal @backtrace.parsed_entries, @backtrace.project_entries
    assert_equal @backtrace.parsed_entries.first, @backtrace.project_entries.first
    refute_equal @backtrace.parsed_entries.last, @backtrace.project_entries.last
    assert_equal @backtrace.project_entries.first, @backtrace.final_project_location
  end

  def test_keeping_only_source_code_entries
    refute_equal @backtrace.parsed_entries, @backtrace.source_code_entries
    assert_equal @backtrace.parsed_entries.first, @backtrace.source_code_entries.first
    refute_equal @backtrace.parsed_entries.last, @backtrace.source_code_entries.last
    assert_equal @backtrace.project_entries.first, @backtrace.final_source_code_location
  end

  def test_sorting_by_modified_time
    test_file_location = File.expand_path(File.dirname(__FILE__))
    pathname = Pathname.new(test_file_location)
    pathname.utime(Time.now, Time.now)

    assert @backtrace.project_entries.size > 1
    assert_equal @backtrace.recently_modified_entries.first, @backtrace.freshest_project_location
  end

  def test_identifying_last_run_test_line
    refute_equal @backtrace.project_entries, @backtrace.test_entries

    assert_equal @backtrace.project_entries[1], @backtrace.final_test_location
  end
end
