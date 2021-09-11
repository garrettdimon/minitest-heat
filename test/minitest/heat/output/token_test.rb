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
end
