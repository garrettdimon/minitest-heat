# frozen_string_literal: true

require 'test_helper'

class Minitest::ContrivedExamplesTest < Minitest::Test
  # More info?

  # Only run these tests when we need to see representational failure types
  if ENV['FORCE_FAILURES']
    def test_errors_raised_directly_from_test
      raise StandardError.new('Testing Errors Raised Directly from a Test')
    end

    def test_incorrect_assertions
      assert false
    end

    def test_explicit_failures
      flunk 'Testing Flunking'
    end

    def test_skips
      skip 'Testing Skipping'
    end

    def test_internal_exception
      assert ::Minitest::Heat.raise_example_error
    end

    def test_a_really_slow_one
      sleep 0.075
      assert true
    end

    def test_a_custom_error_message_for_an_assertion
      assert false, 'This custom error messages explains why this is bad.'
    end
  end
end
