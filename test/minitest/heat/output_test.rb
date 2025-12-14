# frozen_string_literal: true

require 'test_helper'
require 'stringio'

class Minitest::Heat::OutputTest < Minitest::Test
  def setup
    @stream = StringIO.new
    @output = ::Minitest::Heat::Output.new(@stream)

    @source_filename = "#{Dir.pwd}/test/files/source.rb"
    @test_filename = "#{Dir.pwd}/test/minitest/heat/output_test.rb"
    @location = [@test_filename, 1]
    @source_backtrace = [
      "#{@source_filename}:1:in `method_name'",
      "#{@test_filename}:1:in `other_method_name'"
    ]
  end

  def test_initialization_with_default_stream
    output = ::Minitest::Heat::Output.new

    assert_respond_to output, :print
    assert_respond_to output, :puts
  end

  def test_initialization_with_custom_stream
    stream = StringIO.new
    output = ::Minitest::Heat::Output.new(stream)

    assert_equal stream, output.stream
  end

  def test_print_outputs_to_stream
    @output.print('test')

    assert_equal 'test', @stream.string
  end

  def test_puts_outputs_to_stream_with_newline
    @output.puts('test')

    assert_equal "test\n", @stream.string
  end

  def test_newline_is_alias_for_puts
    @output.newline

    assert_equal "\n", @stream.string
  end

  def test_marker_outputs_marker_token
    @output.marker(:error)

    refute_empty @stream.string
  end

  def test_marker_for_each_issue_type
    issue_types = %i[error broken failure skipped painful slow success]

    issue_types.each do |issue_type|
      stream = StringIO.new
      output = ::Minitest::Heat::Output.new(stream)
      output.marker(issue_type)

      refute_empty stream.string, "Expected marker for #{issue_type}"
    end
  end

  def test_compact_summary_outputs_results
    results = ::Minitest::Heat::Results.new
    timer = ::Minitest::Heat::Timer.new
    timer.start!
    timer.stop!

    @output.compact_summary(results, timer)

    refute_empty @stream.string
  end

  def test_heat_map_outputs_map
    map = ::Minitest::Heat::Map.new
    map.add(@test_filename, 1, :failure, backtrace: [])

    @output.heat_map(map)

    refute_empty @stream.string
  end

  def test_issue_details_handles_failure
    issue = build_issue(passed: false)

    @output.issue_details(issue)

    refute_empty @stream.string
  end

  def test_issue_details_handles_error
    issue = build_issue(error: true, backtrace: @source_backtrace)

    @output.issue_details(issue)

    refute_empty @stream.string
  end

  def test_issue_details_handles_skipped
    issue = build_issue(skipped: true)

    @output.issue_details(issue)

    refute_empty @stream.string
  end

  def test_issue_details_handles_slow
    slow_threshold = Minitest::Heat.configuration.slow_threshold
    issue = build_issue(passed: true, execution_time: slow_threshold)

    @output.issue_details(issue)

    refute_empty @stream.string
  end

  def test_issues_list_outputs_issues
    results = ::Minitest::Heat::Results.new
    results.record(build_issue(passed: false))

    @output.issues_list(results)

    refute_empty @stream.string
  end

  def test_issues_list_respects_issue_priority
    results = ::Minitest::Heat::Results.new
    results.record(build_issue(passed: false))
    results.record(build_issue(error: true, backtrace: @source_backtrace))

    @output.issues_list(results)

    # Both issues should be output
    assert @stream.string.length > 10
  end

  def test_compact_summary_handles_exception_gracefully
    results = Object.new # Invalid results object to trigger error

    # Should not raise, but output guidance
    @output.compact_summary(results, nil)

    assert_includes @stream.string, 'Minitest Heat'
  end

  private

  def build_issue(passed: false, error: false, skipped: false, execution_time: 0.001, backtrace: [])
    ::Minitest::Heat::Issue.new(
      assertions: 1,
      message: 'Test message',
      backtrace: backtrace,
      test_location: @location,
      test_class: 'TestClass',
      test_identifier: 'test_method',
      execution_time: execution_time,
      passed: passed,
      error: error,
      skipped: skipped
    )
  end
end
