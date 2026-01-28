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
    # Root path is not a test file and should be recognized as one
    @location.raw_pathname = '/'
    refute @location.test_file?

    # This is a test file and should be recognized as one
    @location.raw_pathname = @raw_pathname
    assert @location.test_file?
    assert @location.project_file?
  end

  def test_knows_if_source_code_file
    # Root path is not a project file and should be recognized as one
    @location.raw_pathname = '/'
    refute @location.source_code_file?

    # Set up a project source code file
    @location.raw_pathname = "#{Dir.pwd}/lib/minitest/heat.rb"
    assert @location.source_code_file?
    assert @location.project_file?
  end

  def test_knows_if_bundled_file
    # Root path is not a project file and should be recognized as one
    @location.raw_pathname = '/'
    refute @location.bundled_file?

    # Manually create a file in vendor/bundle
    directory = "#{Dir.pwd}/vendor/bundle"
    filename = "heat.rb"
    pathname = "#{directory}/#{filename}"
    FileUtils.mkdir_p(directory)
    FileUtils.touch(pathname)

    @location.raw_pathname = pathname
    refute @location.binstub_file?
    assert @location.bundled_file?
    refute @location.source_code_file?
    refute @location.project_file?

    # Get rid of the manually-created file and directory
    FileUtils.rm_rf(directory)
  end

  def test_knows_if_binstub_file
    # Root path is not a project file and should be recognized as one
    @location.raw_pathname = '/'
    refute @location.bundled_file?

    # Manually create a file in vendor/bundle
    directory = "#{Dir.pwd}/bin"
    filename = "stub"
    pathname = "#{directory}/#{filename}"
    FileUtils.mkdir_p(directory)
    FileUtils.touch(pathname)

    @location.raw_pathname = pathname
    assert @location.binstub_file?
    refute @location.bundled_file?
    refute @location.source_code_file?
    refute @location.project_file?

    # Get rid of the manually-created file and directory
    FileUtils.rm_rf(pathname)
  end

  def test_short_returns_relative_filename_and_line
    expected = "#{@location.relative_filename}:#{@location.line_number}"
    assert_equal expected, @location.short
  end

  def test_absolute_filename_for_existing_file
    assert_equal @raw_pathname, @location.absolute_filename
  end

  def test_absolute_filename_for_non_existent_file
    @location.raw_pathname = 'non_existent.rb'
    assert_equal '(Unrecognized File)', @location.absolute_filename
  end

  def test_pathname_falls_back_when_argument_error
    # Null byte in pathname triggers ArgumentError
    @location.raw_pathname = "test\x00file.rb"
    assert_equal Pathname(Dir.pwd), @location.pathname
  end

  def test_line_number_falls_back_when_not_convertible
    @location.raw_line_number = 'not a number'
    assert_equal 1, @location.line_number
  end

  def test_age_in_seconds_for_existing_file
    age = @location.age_in_seconds
    assert_kind_of Integer, age
    assert_operator age, :>=, 0
  end

  def test_age_in_seconds_for_non_existent_file
    @location.raw_pathname = 'non_existent.rb'
    assert_equal(-1, @location.age_in_seconds)
  end

  def test_mtime_for_existing_file
    mtime = @location.mtime
    assert_kind_of Time, mtime
    refute_equal Time.at(0), mtime
  end

  def test_mtime_for_non_existent_file
    @location.raw_pathname = 'non_existent.rb'
    assert_equal Time.at(0), @location.mtime
  end

  def test_to_h_returns_hash_with_file_line_and_container
    hash = @location.to_h
    assert_kind_of Hash, hash
    assert_equal @location.relative_filename, hash[:file]
    assert_equal @location.line_number, hash[:line]
    assert_equal @container, hash[:container]
  end

  def test_to_h_with_non_existent_file
    @location.raw_pathname = 'non_existent_file.rb'
    hash = @location.to_h
    assert_equal '(Unrecognized File)', hash[:file]
  end
end
