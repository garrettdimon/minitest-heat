# frozen_string_literal: true

require 'test_helper'
require 'json'
require 'open3'
require 'rbconfig'

class Minitest::HeatRecordingErrorTest < Minitest::Test
  def test_recording_error_exits_unsuccessfully_with_text_output
    stdout, stderr, status = run_fixture('--name', 'test_a_unprintable_error')

    assert_equal 1, status.exitstatus, stdout
    assert_includes stderr, 'exception message formatting failed'
    refute_includes stdout, 'encountered an exception'
  end

  def test_recording_error_keeps_json_valid_and_reports_failure
    assert_json_failure('--name', 'test_a_unprintable_error', recorded_tests: 0)
  end

  def test_recording_error_does_not_prevent_recording_other_tests
    assert_json_failure(recorded_tests: 1)
  end

  private

  def assert_json_failure(*, recorded_tests:)
    stdout, stderr, status = run_fixture(*, '--heat-json')

    assert_equal 1, status.exitstatus, stdout
    assert_includes stderr, 'exception message formatting failed'
    result = JSON.parse(stdout)

    assert_equal 'failed', result.fetch('status')
    assert_equal recorded_tests, result.fetch('statistics').fetch('total')
  end

  def run_fixture(*)
    root = File.expand_path('../..', __dir__)
    Open3.capture3(
      { 'MT_NO_PLUGINS' => nil }, RbConfig.ruby, '-Ilib',
      File.join(root, 'test/files/test_recording_error.rb'), *, chdir: root
    )
  end
end
