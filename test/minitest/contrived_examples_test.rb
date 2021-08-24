# frozen_string_literal: true

require 'test_helper'

require_relative 'contrived_exceptions'

# rubocop:disable

# This set of tests and related code only exists to force a range of failure types for improving the
#   visual presentation of the various errors based on different contexts
if ENV['FORCE_FAILURES']

  class Minitest::ContrivedExamplesTest < Minitest::Test # rubocop:disable Style/ClassAndModuleChildren
    def test_incorrect_assertions
      assert false
    end

    def test_a_custom_error_message_for_an_assertion
      assert false, 'This custom error messages explains why this is bad.'
    end

    def test_demonstrate_fail_after_yesterday
      seconds_in_a_day = 24 * 60 * 60
      time = Time.now - seconds_in_a_day
      fail_after time.year, time.month, time.day, "This explicitly failed because it was after #{time}"
    end

    def test_explicit_failures
      flunk 'The test was explicitly flunked'
    end

    def test_explicitly_skipped_example
      skip 'The test was explicitly skipped'
    end

    def test_errors_raised_directly_from_test
      raise StandardError, 'Testing Errors Raised Directly from a Test'
    end

    def test_assert_nothing_raised_but_raise_error
      assert_raises SystemExit do
        ::Minitest::Heat.raise_example_error
      end
    end

    def test_raise_exception_from_issue
      ::Minitest::Heat.raise_example_error
    end

    def test_raise_another_exception_from_location
      ::Minitest::Heat.raise_another_example_error
    end

    def test_a_really_slow_one
      sleep 0.075
      assert true
    end

    private

    def raise_example_error(message)
      -> { raise StandardError, message }
    end
  end
end

# rubocop:enable
