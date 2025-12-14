# frozen_string_literal: true

require 'test_helper'

class Minitest::Heat::Output::MapTest < Minitest::Test
  def setup
    @test_filename = "#{Dir.pwd}/test/minitest/heat/output/map_test.rb"
    @source_filename = "#{Dir.pwd}/test/files/source.rb"
    @location = [@test_filename, 1]
    @source_backtrace = [
      "#{@source_filename}:1:in `method_name'",
      "#{@test_filename}:1:in `other_method_name'"
    ]
  end

  def test_initialization
    results = build_results
    output_map = ::Minitest::Heat::Output::Map.new(results)

    assert_equal results, output_map.results
  end

  def test_tokens_returns_array
    results = build_results
    output_map = ::Minitest::Heat::Output::Map.new(results)

    tokens = output_map.tokens

    assert_instance_of Array, tokens
  end

  def test_tokens_for_empty_results
    results = ::Minitest::Heat::Results.new
    output_map = ::Minitest::Heat::Output::Map.new(results)

    tokens = output_map.tokens

    assert_instance_of Array, tokens
    assert_empty tokens
  end

  def test_tokens_for_results_with_failures
    results = build_results
    results.record(build_issue(passed: false))

    output_map = ::Minitest::Heat::Output::Map.new(results)
    tokens = output_map.tokens

    assert_instance_of Array, tokens
    assert tokens.any?
  end

  def test_tokens_for_results_with_errors
    results = build_results
    results.record(build_issue(error: true, backtrace: @source_backtrace))

    output_map = ::Minitest::Heat::Output::Map.new(results)
    tokens = output_map.tokens

    assert_instance_of Array, tokens
    assert tokens.any?
  end

  def test_tokens_for_results_with_multiple_issues
    results = build_results
    results.record(build_issue(passed: false))
    results.record(build_issue(error: true, backtrace: @source_backtrace))

    output_map = ::Minitest::Heat::Output::Map.new(results)
    tokens = output_map.tokens

    assert_instance_of Array, tokens
    assert tokens.any?
  end

  def test_tokens_contain_valid_token_tuples
    results = build_results
    results.record(build_issue(passed: false))

    output_map = ::Minitest::Heat::Output::Map.new(results)
    tokens = output_map.tokens

    tokens.each do |line_tokens|
      line_tokens.each do |token|
        next if token.nil? || token.empty?

        assert_instance_of Array, token
        assert_equal 2, token.length, "Token should be [style, content]: #{token.inspect}"
        assert_instance_of Symbol, token[0], "First element should be a symbol: #{token.inspect}"
      end
    end
  end

  def test_skips_not_shown_when_problems_exist
    results = build_results
    results.record(build_issue(passed: false))
    results.record(build_issue(skipped: true))

    output_map = ::Minitest::Heat::Output::Map.new(results)
    tokens = output_map.tokens

    # Should produce tokens (for the failure) even if skips exist
    assert tokens.any?
  end

  private

  def build_results
    ::Minitest::Heat::Results.new
  end

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
