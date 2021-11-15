# frozen_string_literal: true

require 'test_helper'

require_relative 'contrived_code'

# rubocop:disable

# This set of tests and related code only exists to force a range of failure types for improving the
#   visual presentation of the various errors based on different contexts
if ENV['FORCE_FAILURES'] || ENV['IMPLODE']

  class Minitest::ContrivedSetupFailuresTest < Minitest::Test
    def setup
      @example_lambda = -> { raise StandardError, 'This happened in the setup' }
    end

    def test_trigger_the_first_exception
      assert true
      @example_lambda.call
    end

    def test_trigger_the_second_exception
      refute false
      @example_lambda.call
    end

    def test_trigger_the_third_exception
      @example_lambda.call
      refute false
    end
  end
end

# rubocop:enable
