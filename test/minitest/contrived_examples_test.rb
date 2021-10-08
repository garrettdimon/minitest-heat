# frozen_string_literal: true

require 'test_helper'

require_relative 'contrived_exceptions'

# rubocop:disable

# This set of tests and related code only exists to force a range of failure types for improving the
#   visual presentation of the various errors based on different contexts
if ENV['FORCE_FAILURES']

  class Minitest::ContrivedExamplesTest < Minitest::Test
    def test_fails_because_of_an_incorrect_assertion
      assert false
    end

    def test_fails_but_shows_a_custom_error_message_for_an_assertion
      assert false, 'This custom error messages explains why this is bad.'
    end

    def test_fails_because_of_two_complex_objects_not_matching
      hash_one = {
        one: 1,
      }
      hash_two = {
        one: 1,
        two: 2
      }
      assert_equal hash_one, hash_two
    end

    def test_fails_because_today_is_after_yesterday
      seconds_in_a_day = 24 * 60 * 60
      time = Time.now - seconds_in_a_day
      fail_after time.year, time.month, time.day, "This explicitly failed because it was after #{time}"
    end

    def test_fails_because_it_was_explicitly_flunked
      flunk 'The test was explicitly flunked'
    end

    def test_raises_an_exception_from_directly_in_a_test
      raise StandardError, 'Testing Errors Raised Directly from a Test'
    end

    def test_raises_a_different_exception_than_the_one_expected
      assert_raises SystemExit do
        ::Minitest::Heat.raise_example_error
      end
    end

    def test_raises_exception_from_a_location_in_source_code_rather_than_test
      ::Minitest::Heat.raise_example_error
    end

    def test_raises_another_exception_from_a_different_location
      ::Minitest::Heat.raise_another_example_error
    end

    private

    def raise_example_error(message)
      -> { raise StandardError, message }
    end
  end
end

# rubocop:enable
