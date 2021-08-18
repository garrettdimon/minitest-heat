# frozen_string_literal: true

require 'test_helper'

class Minitest::Heat::LocationTest < Minitest::Test
  def setup
    @test_location = ["#{Dir.pwd}/test/minitest/heat_test.rb", 23]
    @raw_backtrace = [
      "#{Dir.pwd}/lib/minitest/heat.rb:29:in `method_name'",
      "#{Dir.pwd}/test/minitest/heat_test.rb:27:in `other_method_name'",
      "#{Gem.dir}/gems/minitest-5.14.4/lib/minitest/test.rb:98:in `block (3 levels) in run'",
      "#{Gem.dir}/gems/minitest-5.14.4/lib/minitest/test.rb:195:in `capture_exceptions'",
      "#{Gem.dir}/gems/minitest-5.14.4/lib/minitest/test.rb:95:in `block (2 levels) in run'"
    ]

    @location = Minitest::Heat::Location.new(@test_location, @raw_backtrace)
  end

  def test_knows_test_file_and_lines
    assert_equal '/test/minitest/heat_test.rb', @location.test_file
    assert_equal '23', @location.test_definition_line
    assert_equal '27', @location.test_failure_line
  end

  def test_knows_source_file_and_line
    assert_equal '/lib/minitest/heat.rb', @location.source_file
    assert_equal '29', @location.source_failure_line
  end

  def test_knows_when_problem_is_in_source
    assert @location.failure_in_source?
  end

  def test_knows_when_problem_is_in_test
    # Remove the project source line so the test is the last location
    @raw_backtrace.shift
    @location = Minitest::Heat::Location.new(@test_location, @raw_backtrace)

    assert @location.failure_in_test?
  end
end
