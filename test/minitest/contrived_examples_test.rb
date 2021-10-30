# frozen_string_literal: true

require 'test_helper'

require_relative 'contrived_exceptions'

# rubocop:disable

# This set of tests and related code only exists to force a range of failure types for improving the
#   visual presentation of the various errors based on different contexts
class Minitest::ContrivedExamplesTest < Minitest::Test

  if ENV['FORCE_FAILURES'] || ENV['IMPLODE']
    def test_incorrect_assertion_failure
      assert false
    end

    def test_failing_assertion_with_custom_error_message
      assert false, 'This custom error messages explains why this is bad.'
    end

    def test_match_assertion_failure
      assert_match(/gnirts/, 'string')
    end

    def test_emptiness_assertion_failure
      assert_empty [1]
    end

    def test_respond_to_assertion_failure
      assert_respond_to nil, :nope?
    end

    def test_sameness_assertion_failure
      assert_same 1, Integer('1')
    end

    def test_delta_assertion_failure
      assert_in_delta 3, (3 + 2), 1
    end

    def test_includes_assertion_failure
      assert_includes [1], 2
    end

    def test_instance_of_assertion_failure
      assert_instance_of Integer, 1.0
    end

    def test_nil_assertion_failure
      assert_nil 1
    end

    def test_equality_assertion_failure
      hash_one = {
        one: 1
      }
      hash_two = {
        one: 1,
        two: 2
      }
      assert_equal hash_one, hash_two
    end

    def test_yesterday_should_be_after_today
      seconds_in_a_day = 24 * 60 * 60
      time = Time.now - seconds_in_a_day
      fail_after time.year, time.month, time.day, "This explicitly failed because it was after #{time}"
    end

    def test_explicitly_flunked_example
      flunk 'The test was explicitly flunked'
    end
  end

  if ENV['FORCE_EXCEPTIONS'] || ENV['IMPLODE']
    def test_raises_an_exception_from_directly_in_a_test
      raise StandardError, 'Testing Errors Raised Directly from a Test'
    end

    def test_raises_a_different_exception_than_the_one_expected
      assert_raises SystemExit do
        ::Minitest::Heat.raise_example_error
      end
    end

    def test_nothing_raised_assertion
      assert_nothing_raised "Expect nothing to be raised" do
        raise StandardError.new('Something *was* raised!')
      end
    end

    def test_nothing_thrown_assertion
      assert_nothing_thrown "Expect nothing to be thrown" do
        throw :problem?
      end
    end

    def test_raises_exception_from_a_location_in_source_code_rather_than_test
      ::Minitest::Heat.raise_example_error
    end

    def test_raises_another_exception_from_a_different_location
      ::Minitest::Heat.raise_another_example_error
    end
  end

  private

  def raise_example_error(message)
    -> { raise StandardError, message }
  end
end


# rubocop:enable
