# frozen_string_literal: true

require 'test_helper'

class Minitest::Heat::Output::MarkerTest < Minitest::Test
  def test_without_quantity
    marker = Minitest::Heat::Output::Marker.new(:error)
    assert_equal [:error, 'E'], marker.token
  end

  def test_with_quantity
    marker = Minitest::Heat::Output::Marker.new(:error, 3)
    assert_equal [:error, 'EEE'], marker.token
  end
end
