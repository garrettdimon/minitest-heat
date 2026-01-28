# frozen_string_literal: true

require 'test_helper'

class Minitest::Heat::Output::TokenTest < Minitest::Test
  def setup
    @token = ::Minitest::Heat::Output::Token.new(:success, 'Success')
  end

  def test_converts_token_params_to_a_nice_string
    assert_equal "\e[0;32mSuccess\e[0m", @token.to_s
  end

  def test_converts_token_params_to_vanilla_string_when_styles_disabled
    assert_equal 'Success', @token.to_s(:bland)
  end

  def test_raises_error_for_unrecognized_styles
    token = ::Minitest::Heat::Output::Token.new(:missing_style, 'Success')

    assert_raises ::Minitest::Heat::Output::Token::InvalidStyle do
      token.to_s
    end
  end

  def test_considers_tokens_equivalent_with_same_style_and_content
    token = ::Minitest::Heat::Output::Token.new(:success, 'Success')
    other_token = ::Minitest::Heat::Output::Token.new(:success, 'Success')

    assert_equal token, other_token
  end

  def test_considers_tokens_different_with_different_styles
    token = ::Minitest::Heat::Output::Token.new(:success, 'Success')
    other_token = ::Minitest::Heat::Output::Token.new(:failure, 'Success')

    refute_equal token, other_token
  end

  def test_considers_tokens_different_with_different_content
    token = ::Minitest::Heat::Output::Token.new(:success, 'Success')
    other_token = ::Minitest::Heat::Output::Token.new(:success, 'Failure')

    refute_equal token, other_token
  end

  def test_muted_style_uses_default_color_for_accessibility
    # Muted text should use terminal's default color (39) not gray (37)
    # for readability on both light and dark terminal backgrounds
    token = ::Minitest::Heat::Output::Token.new(:muted, 'muted text')

    assert_equal "\e[2;39mmuted text\e[0m", token.to_s
  end

  def test_italicized_style_uses_default_color_for_accessibility
    # Italicized text should use terminal's default color (39) not gray (37)
    # for readability on both light and dark terminal backgrounds
    token = ::Minitest::Heat::Output::Token.new(:italicized, 'italic text')

    assert_equal "\e[3;39mitalic text\e[0m", token.to_s
  end
end
