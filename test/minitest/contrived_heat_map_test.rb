# frozen_string_literal: true

require 'test_helper'

require_relative 'contrived_code'

# rubocop:disable

# This set of tests and related code only exists to force a range of failure types for improving the
#   visual presentation of the various errors based on different contexts
if ENV['FORCE_FAILURES'] || ENV['IMPLODE']

  class Minitest::ContrivedHeatMapTest < Minitest::Test
    def test_trigger_the_first_exception
      example_indirect_code(raise_error: true)
      assert true
    end

    def test_trigger_the_second_exception
      other_example_indirect_code(raise_error: true)
      refute false
    end

    def test_trigger_the_third_exception
      even_more_example_indirect_code(raise_error: true)
      refute false
    end

    private

    # Both tests call this method which then calls a different method
    def example_indirect_code(raise_error: false)
      return unless raise_error

      raise_error_indirectly
    end

    # Both tests call this method which then calls a different method
    def other_example_indirect_code(raise_error: false)
      return unless raise_error

      even_more_example_indirect_code(raise_error: raise_error)
    end

    # Both tests call this method which then calls a different method
    def even_more_example_indirect_code(raise_error: false)
      return unless raise_error

      raise_error_indirectly
    end

    def raise_error_indirectly
      # Both tests should end up here and thus have duplicate entries in the heat map
      raise StandardError, 'Here is an indirectly-raised exception'
    end
  end
end

# rubocop:enable
