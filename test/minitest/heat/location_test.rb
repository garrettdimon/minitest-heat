# frozen_string_literal: true

require 'test_helper'

class Minitest::Heat::LocationTest < Minitest::Test
  def setup
    @project_dir = Dir.pwd
    @gem_dir = Gem.dir

    @test_location = ["#{@project_dir}/test/minitest/heat_test.rb", 23]
    @raw_backtrace = [
      "#{@project_dir}/lib/minitest/heat.rb:29:in `method_name'",
      "#{@project_dir}/test/minitest/heat_test.rb:27:in `other_method_name'",
      "#{@gem_dir}/gems/minitest-5.14.4/lib/minitest/test.rb:98:in `block (3 levels) in run'",
      "#{@gem_dir}/gems/minitest-5.14.4/lib/minitest/test.rb:195:in `capture_exceptions'",
      "#{@gem_dir}/gems/minitest-5.14.4/lib/minitest/test.rb:95:in `block (2 levels) in run'"
    ]

    @location = Minitest::Heat::Location.new(@test_location, @raw_backtrace)
  end

  def test_can_be_initialized_without_backtrace
    location = Minitest::Heat::Location.new(@test_location)
    assert_nil location.source_code_file
    refute_nil location.project_file
    refute_nil location.test_file
    refute_nil location.final_file
  end

  def test_knows_test_file_and_lines
    assert_equal Pathname("#{@project_dir}/test/minitest/heat_test.rb"), @location.test_file
    assert_equal '23', @location.test_definition_line
    assert_equal '27', @location.test_failure_line
  end

  def test_knows_source_code_file_and_line
    assert_equal Pathname("#{@project_dir}/lib/minitest/heat.rb"), @location.source_code_file
    assert_equal '29', @location.source_code_failure_line
  end

  def test_knows_when_problem_is_in_source
    assert @location.proper_failure?
  end

  def test_knows_when_problem_is_in_test
    # Remove the project source line so the test is the last location
    @raw_backtrace.shift
    @location = Minitest::Heat::Location.new(@test_location, @raw_backtrace)

    assert @location.broken_test?
  end

  def test_backtrace_without_source_code_lines
    # Remove the project source line so the test is the last location
    @raw_backtrace.shift
    assert_nil @location.source_code_file
    refute_nil @location.project_file
    refute_nil @location.test_file
    refute_nil @location.final_file
  end

  def test_backtrace_without_source_or_test_lines
    # Remove the project source line so the test is the last location
    @raw_backtrace.shift

    # Remove the project test line so an external file is the last location
    @raw_backtrace.shift

    assert_nil @location.source_code_file
    refute_nil @location.test_file
    refute_nil @location.final_file
  end
end
