# frozen_string_literal: true

require 'test_helper'

class Minitest::Heat::Output::MarkerTest < Minitest::Test
  def test_token
    marker = Minitest::Heat::Output::Marker.new(:error)
    assert_equal [:error, 'E'], marker.token
  end

  def test_for_unknown_issue_type
    marker = Minitest::Heat::Output::Marker.new(:fake_type)
    assert_equal [:default, '?'], marker.token
  end
end
