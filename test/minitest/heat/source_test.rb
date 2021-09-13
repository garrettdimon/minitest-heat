# frozen_string_literal: true

require 'test_helper'

class Minitest::Heat::SourceTest < Minitest::Test
  def setup
    @filename = "#{Dir.pwd}/test/files/source.rb"
    @source = Minitest::Heat::Source.new(@filename, line_number: 5)
    @file_lines = File.readlines(@filename, chomp: true)
  end

  def test_fails_gracefully_when_it_cannot_read_a_file
    @filename = "/file/does/not/exist.rb"
    @source = Minitest::Heat::Source.new(@filename, line_number: 1)

    assert_equal [], @source.file_lines
  end

  def test_converts_to_hash
    @source.max_line_count = 1
    source_hash = {"5"=>"else"}
    assert_equal source_hash, @source.to_h
  end

  def test_chomps_lines
    raw_file_lines = File.readlines(@filename, chomp: false)
    assert_equal 14, raw_file_lines.length
    assert_equal 9, @source.file_lines.length
  end

  def test_retrieves_source_line
    assert_equal "else", @source.line
  end

  def test_retrieves_array_of_one_line_by_default
    assert_equal [@source.line], @source.lines
  end

  def test_includes_two_surrounding_lines
    @source.max_line_count = 3
    assert_equal [4, 5, 6], @source.line_numbers
    assert_equal @file_lines[3..5], @source.lines
  end

  def test_includes_two_preceding_lines
    @source.max_line_count = 3
    @source.context = :before
    assert_equal [3, 4, 5], @source.line_numbers
    assert_equal @file_lines[2..4], @source.lines
  end

  def test_limits_first_line_to_first_line_of_file
    @source.line_number = 1
    @source.max_line_count = 3
    @source.context = :before
    assert_equal [1, 2, 3], @source.line_numbers
    assert_equal @file_lines[0..2], @source.lines
  end

  def test_includes_one_surrounding_line_on_either_side
    @source.max_line_count = 3
    @source.context = :around
    assert_equal [4, 5, 6], @source.line_numbers
    assert_equal @file_lines[3..5], @source.lines
  end

  def test_limits_lines_to_maximum_in_file
    @source.line_number = 1
    @source.max_line_count = 20
    @source.context = :around
    assert_equal (1..9).to_a, @source.line_numbers
    assert_equal @file_lines[0..8], @source.lines
  end

  def test_includes_two_following_lines
    @source.max_line_count = 3
    @source.context = :after
    assert_equal [5, 6, 7], @source.line_numbers
    assert_equal @file_lines[4..6], @source.lines
  end

  def test_limits_last_line_to_last_line_of_file
    @source.line_number = @source.file_lines.length
    @source.max_line_count = 3
    @source.context = :after
    assert_equal [7, 8, 9], @source.line_numbers
    assert_equal @file_lines[6..8], @source.lines
  end
end
