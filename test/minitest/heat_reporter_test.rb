# frozen_string_literal: true

require 'test_helper'
require 'minitest/heat_reporter'
require 'stringio'
require 'json'

class Minitest::HeatReporterTest < Minitest::Test
  def setup
    @io = StringIO.new
    @options = {}
    @reporter = Minitest::HeatReporter.new(@io, @options)
  end

  def test_passed_is_public_method
    # Minitest calls passed? on reporters to determine overall result
    assert_respond_to @reporter, :passed?
    refute @reporter.passed?.nil?
  end

  def test_passed_returns_true_when_no_failures_or_errors
    @reporter.start

    assert @reporter.passed?
  end

  def test_passed_returns_false_when_failures_exist
    @reporter.start
    @reporter.results.record(build_issue(passed: false))

    refute @reporter.passed?
  end

  def test_json_output_is_false_by_default
    refute @reporter.json_output?
  end

  def test_json_output_is_true_when_option_set
    reporter = Minitest::HeatReporter.new(@io, heat_json: true)

    assert reporter.json_output?
  end

  def test_report_outputs_json_when_json_output_enabled
    reporter = Minitest::HeatReporter.new(@io, heat_json: true)
    reporter.start
    reporter.timer.stop!

    reporter.report

    output = @io.string
    parsed = JSON.parse(output)

    assert_equal '1.0', parsed['version']
    assert parsed.key?('statistics')
    assert parsed.key?('timing')
    assert parsed.key?('heat_map')
    assert parsed.key?('issues')
  end

  def test_report_outputs_text_by_default
    @reporter.start
    @reporter.timer.stop!

    @reporter.report

    output = @io.string
    # Text output doesn't start with JSON brace
    refute output.strip.start_with?('{')
  end
end
