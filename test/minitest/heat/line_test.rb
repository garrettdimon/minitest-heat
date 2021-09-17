# frozen_string_literal: true

require 'test_helper'

class Minitest::Heat::LineTest < Minitest::Test
  def setup
    @filename = __FILE__
    @pathname = Pathname(@filename)
    @line_number = 23
    @container = 'method_name'

    @line = ::Minitest::Heat::Line.new(pathname: @pathname, number: @line_number, container: @container)
  end

  def test_can_initilize_without_container
    @line = ::Minitest::Heat::Line.new(pathname: @pathname, number: @line_number)

    assert_equal '', @line.container
  end

  def test_casts_to_array
    assert_equal [@line.pathname, @line.number], @line.to_a
  end

  def test_casts_to_string
    assert_equal "#{@line.pathname}:#{@line.number} in `#{@line.container}`", @line.to_s
  end

  def test_fails_gracefully_when_it_cannot_read_a_file
    @raw_pathname = "/file/does/not/exist.rb"
    @line = ::Minitest::Heat::Line.new(pathname: @raw_pathname, number: @line_number, container: @container)

    refute_nil @line
    refute_nil @line.path
    refute_nil @line.file
    refute_nil @line.mtime
  end

  # def test_parsing
  #   parsed_backtrace_line = Minitest::Heat::Backtrace::Line.new(
  #     pathname: Pathname(__FILE__),
  #     number: '29',
  #     container: 'method_name'
  #   )

  #   assert_equal parsed_backtrace_line, @backtrace.parsed_lines.first
  #   assert_equal @backtrace.parsed_lines.first, @backtrace.final_location
  # end

  # def test_backtrace_line
  #   pathname = Pathname(__FILE__)
  #   number = '29'
  #   container = 'method_name'

  #   parsed_backtrace_line = Minitest::Heat::Backtrace::Line.new(
  #     pathname: pathname,
  #     number: number,
  #     container: container
  #   )

  #   assert_match(/test\/minitest\/heat\/backtrace_test\.rb\:29 in `method_name`/, parsed_backtrace_line.to_s)
  #   assert_match(/test\/minitest\/heat\/backtrace_test\.rb\:29/, parsed_backtrace_line.location)
  #   assert_match(/test\/minitest\/heat\/backtrace_test\.rb/, parsed_backtrace_line.pathname.to_s)
  #   assert_match(/backtrace_test\.rb\:29/, parsed_backtrace_line.short_location)
  # end

end
