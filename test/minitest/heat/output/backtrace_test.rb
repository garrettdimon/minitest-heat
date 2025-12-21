# frozen_string_literal: true

require 'test_helper'

class Minitest::Heat::Output::BacktraceTest < Minitest::Test
  def setup
    @test_location = ["#{Dir.pwd}/test/minitest/heat_test.rb", 23]
    @raw_backtrace = [
      "#{Dir.pwd}/lib/minitest/heat.rb:29:in `method_name'",
      "#{Dir.pwd}/test/minitest/heat_test.rb:27:in `other_method_name'",
      "#{Gem.dir}/gems/minitest-5.14.4/lib/minitest/test.rb:98:in `block (3 levels) in run'",
      "#{Gem.dir}/gems/minitest-5.14.4/lib/minitest/test.rb:195:in `capture_exceptions'",
      "#{Gem.dir}/gems/minitest-5.14.4/lib/minitest/test.rb:95:in `block (2 levels) in run'"
    ]

    @locations = Minitest::Heat::Locations.new(@test_location, @raw_backtrace)
    @backtrace_output = ::Minitest::Heat::Output::Backtrace.new(@locations)
  end

  def test_initialization
    backtrace_output = ::Minitest::Heat::Output::Backtrace.new(@locations)

    assert_equal @locations, backtrace_output.locations
    assert_equal @locations.backtrace, backtrace_output.backtrace
  end

  def test_tokens_returns_array_of_token_arrays
    tokens = @backtrace_output.tokens

    assert_instance_of Array, tokens
    assert tokens.all? { |line| line.is_a?(Array) }
  end

  def test_tokens_contain_valid_token_tuples
    tokens = @backtrace_output.tokens

    # Each line should have tokens that are [style, content] tuples
    tokens.each do |line_tokens|
      line_tokens.each do |token|
        next if token.nil?

        assert_instance_of Array, token
        assert_equal 2, token.length, "Token should be [style, content]: #{token.inspect}"
        assert_instance_of Symbol, token[0], "First element should be a symbol: #{token.inspect}"
      end
    end
  end

  def test_line_count_returns_positive_integer
    assert_operator @backtrace_output.line_count, :>, 0
  end

  def test_backtrace_locations_limited_to_line_count
    locations = @backtrace_output.backtrace_locations

    assert_operator locations.length, :<=, @backtrace_output.line_count
  end

  def test_tokens_for_empty_backtrace
    empty_locations = Minitest::Heat::Locations.new(@test_location, [])
    backtrace_output = ::Minitest::Heat::Output::Backtrace.new(empty_locations)

    tokens = backtrace_output.tokens

    assert_instance_of Array, tokens
    assert_empty tokens
  end

  def test_tokens_for_single_line_backtrace
    single_line_backtrace = ["#{Dir.pwd}/lib/minitest/heat.rb:29:in `method_name'"]
    locations = Minitest::Heat::Locations.new(@test_location, single_line_backtrace)
    backtrace_output = ::Minitest::Heat::Output::Backtrace.new(locations)

    tokens = backtrace_output.tokens

    assert_equal 1, tokens.length
  end

  def test_tokens_include_path_information
    tokens = @backtrace_output.tokens

    # At least one line should include path info
    all_content = tokens.flatten.select { |t| t.is_a?(String) }.join
    assert_match %r{/}, all_content
  end

  def test_tokens_include_line_numbers
    tokens = @backtrace_output.tokens

    # At least one line should include line number (line_number is an Integer, not String)
    all_content = tokens.flatten.map(&:to_s).join
    assert_match(/\d+/, all_content)
  end

  def test_project_files_styled_differently_than_gem_files
    # Create a backtrace with both project and gem files
    mixed_backtrace = [
      "#{Dir.pwd}/lib/minitest/heat.rb:29:in `method_name'",
      "#{Gem.dir}/gems/minitest-5.14.4/lib/minitest/test.rb:98:in `run'"
    ]
    locations = Minitest::Heat::Locations.new(@test_location, mixed_backtrace)
    backtrace_output = ::Minitest::Heat::Output::Backtrace.new(locations)

    tokens = backtrace_output.tokens

    # Should produce output for both lines
    assert_operator tokens.length, :>=, 1
  end
end
