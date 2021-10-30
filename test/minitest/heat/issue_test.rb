# frozen_string_literal: true

require 'test_helper'

class Minitest::Heat::IssueTest < Minitest::Test
  def setup
    # # Raise, rescue, and assign an exception instance to ensure the full context
    @exception = begin
      raise ::Minitest::UnexpectedError.new
    rescue => e
      return e
    end

    @location = [Pathname(__FILE__), 1]

    @issue = ::Minitest::Heat::Issue.new
  end

  def test_converts_to_a_hit
    # refute_nil @issue
    # expected_hit = []
    # assert_equal expected_hit, @issue.to_hit
  end
end
