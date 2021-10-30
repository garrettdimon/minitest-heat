# frozen_string_literal: true

require 'test_helper'

class Minitest::Heat::IssueTest < Minitest::Test
  def setup
    # # Raise, rescue, and assign an exception instance to ensure the full context
    # @failure = begin
    #   raise ::Minitest::UnexpectedError.new
    # rescue => e
    #   return e
    # end

    # # Build a Minitest Result
    # @result = ::Minitest::Result.new('Example Test Name')
    # @result.failures << @failure
    # @result.time = Time.now

    # @issue = ::Minitest::Heat::Issue.from_result(@result)

    # ap @issue
  end

  def test_converts_to_a_hit
    # refute_nil @issue
    # expected_hit = []
    # assert_equal expected_hit, @issue.to_hit
  end
end
