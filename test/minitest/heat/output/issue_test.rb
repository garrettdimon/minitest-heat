# frozen_string_literal: true

require 'test_helper'

class Minitest::Heat::Output::IssueTest < Minitest::Test
  def setup
    @source_filename = "#{Dir.pwd}/test/files/source.rb"
    @test_filename = "#{Dir.pwd}/test/minitest/heat/output/issue_test.rb"
    @location = [@test_filename, 1]
    @source_backtrace = [
      "#{@source_filename}:1:in `method_name'",
      "#{@test_filename}:1:in `other_method_name'"
    ]
  end

  def test_initialization
    issue = build_issue(passed: false)
    output_issue = ::Minitest::Heat::Output::Issue.new(issue)

    assert_equal issue, output_issue.issue
    assert_equal issue.locations, output_issue.locations
  end

  def test_tokens_for_failure
    issue = build_issue(passed: false)
    output_issue = ::Minitest::Heat::Output::Issue.new(issue)

    tokens = output_issue.tokens

    assert_instance_of Array, tokens
    assert tokens.any?
  end

  def test_tokens_for_error
    issue = build_issue(error: true, backtrace: @source_backtrace)
    output_issue = ::Minitest::Heat::Output::Issue.new(issue)

    tokens = output_issue.tokens

    assert_instance_of Array, tokens
    assert tokens.any?
  end

  def test_tokens_for_broken
    # Broken = error with test file first in backtrace
    test_backtrace = @source_backtrace.reverse
    issue = build_issue(error: true, backtrace: test_backtrace)
    output_issue = ::Minitest::Heat::Output::Issue.new(issue)

    tokens = output_issue.tokens

    assert_instance_of Array, tokens
    assert tokens.any?
  end

  def test_tokens_for_skipped
    issue = build_issue(skipped: true)
    output_issue = ::Minitest::Heat::Output::Issue.new(issue)

    tokens = output_issue.tokens

    assert_instance_of Array, tokens
    assert tokens.any?
  end

  def test_tokens_for_slow
    slow_threshold = Minitest::Heat.configuration.slow_threshold
    issue = build_issue(passed: true, execution_time: slow_threshold)
    output_issue = ::Minitest::Heat::Output::Issue.new(issue)

    tokens = output_issue.tokens

    assert_instance_of Array, tokens
    assert tokens.any?
  end

  def test_tokens_for_painful
    painful_threshold = Minitest::Heat.configuration.painfully_slow_threshold
    issue = build_issue(passed: true, execution_time: painful_threshold + 1.0)
    output_issue = ::Minitest::Heat::Output::Issue.new(issue)

    tokens = output_issue.tokens

    assert_instance_of Array, tokens
    assert tokens.any?
  end

  def test_tokens_contain_valid_token_tuples
    issue = build_issue(passed: false)
    output_issue = ::Minitest::Heat::Output::Issue.new(issue)
    tokens = output_issue.tokens

    tokens.each do |line_tokens|
      line_tokens.each do |token|
        next if token.nil? || token.empty?

        assert_instance_of Array, token
        assert_equal 2, token.length, "Token should be [style, content]: #{token.inspect}"
        assert_instance_of Symbol, token[0], "First element should be a symbol: #{token.inspect}"
      end
    end
  end

  def test_tokens_for_success_returns_nil
    # Use execution_time: 0.0 to ensure it's below slow_threshold and truly a success
    issue = build_issue(passed: true, execution_time: 0.0)
    output_issue = ::Minitest::Heat::Output::Issue.new(issue)

    tokens = output_issue.tokens

    # Success issues don't have output tokens
    assert_nil tokens
  end

  private

  def build_issue(passed: false, error: false, skipped: false, execution_time: 0.001, backtrace: [])
    ::Minitest::Heat::Issue.new(
      assertions: 1,
      message: 'Test message',
      backtrace: backtrace,
      test_location: @location,
      test_class: 'TestClass',
      test_identifier: 'test_method',
      execution_time: execution_time,
      passed: passed,
      error: error,
      skipped: skipped
    )
  end
end
