# frozen_string_literal: true

require 'test_helper'

require_relative 'contrived_code'

# rubocop:disable

# This set of tests and related code only exists to force a range of failure types for improving the
#   visual presentation of the various errors based on different contexts
if ENV['FORCE_FAILURES'] || ENV['IMPLODE']

  class Minitest::ContrivedSetupFailuresTest < Minitest::Test
    def setup
      example_indirect_code(raise_error: true)
    end

    def test_trigger_the_first_exception
      assert true
    end

    def test_trigger_the_second_exception
      refute false
    end

    def test_trigger_the_third_exception
      refute false
    end

    private

    # Both tests call this method which then calls a different method
    def example_indirect_code(raise_error: false)
      return unless raise_error

      raise_error_indirectly
    end

    def raise_error_indirectly
      # Both tests should end up here and thus have duplicate entries in the heat map
      raise StandardError, 'Here is an indirectly raise exception'
    end
  end
end

# rubocop:enable
