# frozen_string_literal: true

require 'test_helper'

require_relative 'contrived_code'

# rubocop:disable

# This set of tests and related code only exists to force a range of failure types for improving the
#   visual presentation of the various errors based on different contexts
if ENV['FORCE_SKIPS'] || ENV['FORCE_SLOWS'] || ENV['IMPLODE']

  class Minitest::ContrivedSkipsAndSlowsTest < Minitest::Test
    def test_something_that_is_not_ready_yet
      return if ENV['FORCE_SLOWS']

      skip 'The test was explicitly skipped'
    end

    def test_something_temporarily_broken
      return if ENV['FORCE_SLOWS']

      skip 'The test is temporarily broken'
    end

    def test_exposes_when_tests_are_slow
      config = Minitest::Heat.configuration
      # Sleep at midpoint between slow and painful thresholds
      sleep (config.slow_threshold + config.painfully_slow_threshold) / 2.0
      assert true
    end

    def test_exposes_when_tests_are_top_three_slow
      # Sleep above painful threshold
      sleep Minitest::Heat.configuration.painfully_slow_threshold * 2.0
      assert true
    end

    def test_exposes_when_tests_are_slow_but_not_top_three
      config = Minitest::Heat.configuration
      # Sleep just above slow threshold but well below painful
      sleep config.slow_threshold + ((config.painfully_slow_threshold - config.slow_threshold) * 0.25)
      assert true
    end

    private

    def raise_example_error(message)
      -> { raise StandardError, message }
    end
  end
end

# rubocop:enable
