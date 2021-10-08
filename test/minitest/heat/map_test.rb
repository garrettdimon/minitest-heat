# frozen_string_literal: true
require 'test_helper'

class Minitest::Heat::MapTest < Minitest::Test
  def setup
    @map = Minitest::Heat::Map.new
    @filename = 'dir/file.rb'
  end

  def test_initializes_hits
    assert_equal({}, @map.hits)
  end

  def test_initializes_new_file_entries_total
    @map.add(@filename, 5, :error)
    assert_equal 1, @map.hits[@filename].count
  end

  def test_initializes_new_file_entries_with_affected_type_line_number_entry
    @map.add(@filename, 5, :error)
    assert_includes @map.hits[@filename].issues[:error], 5
  end

  def test_returns_sorted_list_of_files
    4.times { @map.add("four_#{@filename}", 1, :error) }
    2.times { @map.add("two_#{@filename}", 1, :error) }
    3.times { @map.add("three_#{@filename}", 1, :error) }
    3.times { @map.add("three_#{@filename}", 1, :failure) }
    2.times { @map.add("two_#{@filename}", 1, :failure) }

    files = @map.file_hits

    assert_equal 3, files.size
    largest_weight = files[0].weight
    smallest_weight = files[2].weight
    assert largest_weight > smallest_weight
  end

  def test_logs_issues
    @map.add(@filename, 5, :error)
    @map.add(@filename, 8, :error)

    hit = @map.hits[@filename]

    assert_equal 6, hit.weight
    assert_equal 2, hit.count
    assert_equal [5, 8], hit.line_numbers
  end
end
