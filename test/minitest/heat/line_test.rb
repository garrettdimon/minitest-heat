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

  def test_casts_to_string
    assert_equal "#{@line.pathname}:#{@line.number} in `#{@line.container}`", @line.to_s
  end

  def test_fails_gracefully_with_invalid_values
    line = ::Minitest::Heat::Line.new(pathname: 'fake', number: nil, container: nil)
    refute_nil line

    assert_equal('(Unrecognized File)', line.path)
    assert_equal('(Unrecognized File)', line.file)
    assert_equal(Time.at(0), line.mtime)
    assert_equal(-1, line.age_in_seconds)
  end

  def test_parsing
    fake_backtrace = "#{__FILE__}:1:in `capture_exceptions'"
    line = Minitest::Heat::Line.parse_backtrace(fake_backtrace)

    assert_equal Pathname(__FILE__), line.pathname
    assert_equal 1, line.number
    assert_equal 'capture_exceptions', line.container
  end

  def test_backtrace_line
    pathname = Pathname(__FILE__)
    number = '29'
    container = 'method_name'

    line = Minitest::Heat::Line.new(
      pathname: pathname,
      number: number,
      container: container
    )

    assert_match(/test\/minitest\/heat\/line_test\.rb\:29 in `method_name`/, line.to_s)
    assert_match(/test\/minitest\/heat\/line_test\.rb\:29/, line.location)
    assert_match(/test\/minitest\/heat\/line_test\.rb/, line.pathname.to_s)
    assert_match(/line_test\.rb\:29/, line.short_location)
  end

end
