# frozen_string_literal: true

require 'test_helper'

class Minitest::Heat::HitTest < Minitest::Test
  def setup
    @filename = __FILE__
    @type = :error
    @line_number = 23

    @pathname = Pathname(@filename)

    @hit = ::Minitest::Heat::Hit.new(@filename)
  end

  def test_starts_with_empty_values
    assert_equal 0, @hit.weight
    assert_equal 0, @hit.count
    assert_empty @hit.issues
    assert_empty @hit.line_numbers
  end

  def test_knows_file_freshness
    assert_equal @pathname, @hit.pathname
    assert_equal @pathname.mtime, @hit.mtime

    expected_age_in_seconds = (Time.now - @hit.mtime).to_i
    assert_equal expected_age_in_seconds, @hit.age_in_seconds
  end

  def test_logs_issues
    @hit.log(@type, @line_number)

    refute_empty @hit.issues
  end

  def test_calculates_hit_weight
    @hit.log(@type, @line_number)

    expected_weight = ::Minitest::Heat::Hit::WEIGHTS[@type]
    assert_equal expected_weight, @hit.weight
  end

  def test_calculates_hit_count
    @hit.log(@type, @line_number)

    assert_equal 1, @hit.count
  end

  def test_tracks_line_numbers
    @hit.log(@type, @line_number)

    assert_includes @hit.line_numbers, @line_number
  end
end
