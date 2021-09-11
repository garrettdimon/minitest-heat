# frozen_string_literal: true

require 'test_helper'

class Minitest::Heat::Output::SourceCodeTest < Minitest::Test
  def setup
    @filename = __FILE__
    @line_number = 3
    @source_code = ::Minitest::Heat::Output::SourceCode.new(@filename, @line_number)
  end

  def test_knows_max_line_number_digits
    @source_code = ::Minitest::Heat::Output::SourceCode.new(@filename, 3)
    assert_equal 1, @source_code.max_line_number_digits

    @source_code = ::Minitest::Heat::Output::SourceCode.new(@filename, 10)
    assert_equal 2, @source_code.max_line_number_digits
  end

  def test_defaults_to_three_lines_of_code
    # One line specified, so we should only have one line of tokens
    assert_equal 3, @source_code.max_line_count
    assert_equal 3, @source_code.tokens.size
  end

  def test_limits_lines_of_code_to_max_line_count
    @source_code = ::Minitest::Heat::Output::SourceCode.new(@filename, @line_number, max_line_count: 1)

    # One line specified, so we should only have one line of tokens
    assert_equal 1, @source_code.max_line_count
    assert_equal 1, @source_code.tokens.size
  end

  def test_builds_tokens_for_lines_of_code
    @source_code = ::Minitest::Heat::Output::SourceCode.new(@filename, @line_number, max_line_count: 1)

    # Line number token has spacing
    expected_line_number_token = ::Minitest::Heat::Output::Token.new(:default, "  #{@line_number.to_s} ")
    expected_line_of_code_token = ::Minitest::Heat::Output::Token.new(:default, "require 'test_helper'")

    line = @source_code.tokens.first
    assert_equal expected_line_number_token, line[0]
    assert_equal expected_line_of_code_token, line[1]
  end
end
