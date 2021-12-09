# frozen_string_literal: true

require 'test_helper'

class Minitest::Heat::LocationTest < Minitest::Test
  def setup
    @raw_pathname = __FILE__
    @raw_line_number = 8
    @container = 'setup'

    @location = ::Minitest::Heat::Location.new(pathname: @raw_pathname, line_number: @raw_line_number, container: @container)
  end

  def test_full_initialization
    assert_equal Pathname(@raw_pathname), @location.pathname
    assert_equal Integer(@raw_line_number), @location.line_number
    assert_equal @container, @location.container
    refute_nil @location.source_code
    assert @location.exists?
  end

  def test_no_container
    @location.raw_container = nil
    assert_equal Pathname(@raw_pathname), @location.pathname
    assert_equal Integer(@raw_line_number), @location.line_number
    assert_equal '(Unknown Container)', @location.container
    refute_empty @location.source_code.lines
    assert @location.exists?
  end

  def test_non_existent_file
    fake_file_name = 'fake_file.rb'
    @location.raw_pathname = fake_file_name

    assert_equal Pathname(fake_file_name), @location.pathname
    assert_empty @location.source_code.lines
    refute @location.exists?
  end

  def test_non_existent_line_number
    fake_line_number = 1_000_000
    @location.raw_line_number = fake_line_number

    assert_equal fake_line_number, @location.line_number
    assert_empty @location.source_code.lines
    refute @location.exists?
  end

  def test_extracting_path
    assert_equal "#{Dir.pwd}/test/minitest/heat", @location.path
  end

  def test_extracting_filename
    assert_equal 'location_test.rb', @location.filename
  end

  def test_absolute_path
    assert_equal "#{Dir.pwd}/test/minitest/heat/", @location.absolute_path
  end

  def test_relative_path
    assert_equal 'test/minitest/heat/', @location.relative_path
  end

  def test_casts_to_string
    assert_equal "#{@location.pathname}:#{@location.line_number} in `#{@location.container}`", @location.to_s
  end

  def test_knows_if_test_file
    # This is a test file and should be recognized as one
    assert @location.test_file?
    assert @location.project_file?

    # Root path is not a test file and should be recognized as one
    @location.raw_pathname = '/'
    refute @location.test_file?
  end

  def test_knows_if_source_code_file
    @location.raw_pathname = "#{Dir.pwd}/lib/minitest/heat.rb"
    assert @location.source_code_file?
    assert @location.project_file?

    # Root path is not a project file and should be recognized as one
    @location.raw_pathname = '/'
    refute @location.source_code_file?
  end
end
