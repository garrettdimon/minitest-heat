# frozen_string_literal: true

require 'test_helper'

class Minitest::Heat::Backtrace::LineParserParserTest < Minitest::Test
  def setup
    @filename = __FILE__
    @line_number = 23
    @container = 'method_name'
    backtrace_line = "#{@filename}:#{@line_number}:in `#{@container}'"

    @location = Minitest::Heat::Backtrace::LineParser.read(backtrace_line)
  end

  def test_parsing_extracts_pathname
    assert_equal Pathname(@filename), @location.pathname
  end

  def test_parsing_extracts_line_number
    assert_equal @line_number, @location.line_number
  end

  def test_parsing_extracts_container
    assert_equal @container, @location.container
  end

  def test_parsing_preserves_namespaced_container
    location = Minitest::Heat::Backtrace::LineParser.read("#{@filename}:23:in `Example::Test#test_failure'")

    assert_equal 'Example::Test#test_failure', location.container
  end

  def test_parsing_handles_single_quoted_container
    location = Minitest::Heat::Backtrace::LineParser.read("#{@filename}:23:in 'Example::Test#test_failure'")

    assert_equal 'Example::Test#test_failure', location.container
  end

  def test_parsing_preserves_real_ruby_backtrace_label
    error = assert_raises(RuntimeError) { raise 'example failure' }
    location = Minitest::Heat::Backtrace::LineParser.read(error.backtrace.first)

    assert_equal error.backtrace_locations.first.label, location.container
  end
end
