# frozen_string_literal: true

require 'test_helper'

require_relative 'contrived_exceptions'

# rubocop:disable

# This set of tests and related code only exists to force a range of failure types for improving the
#   visual presentation of the various errors based on different contexts
if ENV['FORCE_SKIPS'] || ENV['FORCE_FAILURES']

  class Minitest::ContrivedSkipsAndSlowsTest < Minitest::Test # rubocop:disable Style/ClassAndModuleChildren
    def test_skips_the_test_because_its_not_ready
      skip 'The test was explicitly skipped'
    end

    def test_skips_the_test_because_its_temporarily_broken
      skip 'The test is temporarily broken'
    end

    def test_exposes_when_tests_are_slow
      sleep Minitest::Heat::Issue::SLOW_THRESHOLDS[:slow] + 0.1
      assert true
    end

    def test_exposes_when_tests_are_top_three_slow
      sleep Minitest::Heat::Issue::SLOW_THRESHOLDS[:painful] + 0.1
      assert true
    end

    def test_exposes_when_tests_are_slow_but_not_top_three
      sleep Minitest::Heat::Issue::SLOW_THRESHOLDS[:slow] + 0.05
      assert true
    end

    private

    def raise_example_error(message)
      -> { raise StandardError, message }
    end
  end
end

# rubocop:enable