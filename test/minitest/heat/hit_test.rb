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

  def test_to_h_returns_file_weight_and_lines
    @hit.log(:error, 10)
    @hit.log(:failure, 20)
    @hit.log(:failure, 10)

    hash = @hit.to_h

    assert_kind_of Hash, hash
    assert_equal 'test/minitest/heat/hit_test.rb', hash[:file]
    assert_equal @hit.weight, hash[:weight]
    assert_kind_of Array, hash[:lines]
    assert_equal 2, hash[:lines].size
  end

  def test_to_h_lines_include_type_and_count
    @hit.log(:error, 10)
    @hit.log(:failure, 10)

    hash = @hit.to_h
    line_10 = hash[:lines].find { |l| l[:line] == 10 }

    assert_equal 10, line_10[:line]
    assert_includes line_10[:types], :error
    assert_includes line_10[:types], :failure
    assert_equal 2, line_10[:count]
  end
end
