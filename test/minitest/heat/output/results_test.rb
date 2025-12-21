# frozen_string_literal: true

require 'test_helper'

class Minitest::Heat::Output::ResultsTest < Minitest::Test
  def setup
    @test_filename = "#{Dir.pwd}/test/minitest/heat/output/results_test.rb"
    @source_filename = "#{Dir.pwd}/test/files/source.rb"
    @location = [@test_filename, 1]
    @source_backtrace = [
      "#{@source_filename}:1:in `method_name'",
      "#{@test_filename}:1:in `other_method_name'"
    ]
  end

  def test_initialization
    results = build_results
    timer = build_timer

    output_results = ::Minitest::Heat::Output::Results.new(results, timer)

    assert_equal results, output_results.results
    assert_equal timer, output_results.timer
  end

  def test_tokens_returns_array
    results = build_results
    timer = build_timer

    output_results = ::Minitest::Heat::Output::Results.new(results, timer)
    tokens = output_results.tokens

    assert_instance_of Array, tokens
    assert tokens.any?
  end

  def test_tokens_includes_timing_information
    results = build_results
    timer = build_timer

    output_results = ::Minitest::Heat::Output::Results.new(results, timer)
    tokens = output_results.tokens

    # Should have timing info in the token content
    all_content = tokens.flatten.select { |t| t.is_a?(String) }.join
    assert_match(/\ds/, all_content) # Should include seconds
  end

  def test_tokens_includes_test_count
    results = build_results
    results.record(build_issue(passed: true))
    timer = build_timer(test_count: 1)

    output_results = ::Minitest::Heat::Output::Results.new(results, timer)
    tokens = output_results.tokens

    all_content = tokens.flatten.select { |t| t.is_a?(String) }.join
    assert_match(/test/, all_content)
  end

  def test_tokens_includes_assertion_count
    results = build_results
    timer = build_timer(assertion_count: 5)

    output_results = ::Minitest::Heat::Output::Results.new(results, timer)
    tokens = output_results.tokens

    all_content = tokens.flatten.select { |t| t.is_a?(String) }.join
    assert_match(/assertion/, all_content)
  end

  def test_tokens_for_results_with_errors
    results = build_results
    results.record(build_issue(error: true, backtrace: @source_backtrace))
    timer = build_timer

    output_results = ::Minitest::Heat::Output::Results.new(results, timer)
    tokens = output_results.tokens

    assert tokens.any?
  end

  def test_tokens_for_results_with_failures
    results = build_results
    results.record(build_issue(passed: false))
    timer = build_timer

    output_results = ::Minitest::Heat::Output::Results.new(results, timer)
    tokens = output_results.tokens

    assert tokens.any?
  end

  def test_tokens_for_results_with_skips
    results = build_results
    results.record(build_issue(skipped: true))
    timer = build_timer

    output_results = ::Minitest::Heat::Output::Results.new(results, timer)
    tokens = output_results.tokens

    assert tokens.any?
  end

  def test_tokens_contain_valid_token_tuples
    results = build_results
    results.record(build_issue(passed: false))
    timer = build_timer

    output_results = ::Minitest::Heat::Output::Results.new(results, timer)
    tokens = output_results.tokens

    tokens.each do |line_tokens|
      line_tokens.each do |token|
        next if token.nil?

        assert_instance_of Array, token
        assert_equal 2, token.length, "Token should be [style, content]: #{token.inspect}"
        assert_instance_of Symbol, token[0], "First element should be a symbol: #{token.inspect}"
      end
    end
  end

  def test_delegators_work
    results = build_results
    results.record(build_issue(passed: false))
    results.record(build_issue(error: true, backtrace: @source_backtrace))
    timer = build_timer

    output_results = ::Minitest::Heat::Output::Results.new(results, timer)

    assert_respond_to output_results, :issues
    assert_respond_to output_results, :errors
    assert_respond_to output_results, :failures
    assert_respond_to output_results, :problems?
  end
end
