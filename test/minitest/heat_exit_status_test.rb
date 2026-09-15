# frozen_string_literal: true

require 'test_helper'
require 'json'
require 'open3'
require 'rbconfig'

class Minitest::HeatExitStatusTest < Minitest::Test
  def test_broken_test_exits_unsuccessfully
    assert_process_result('broken', 'broken', 1, 1)
  end

  def test_assertion_failure_exits_unsuccessfully
    assert_process_result('failure', 'failures', 1, 1)
  end

  def test_source_error_exits_unsuccessfully
    assert_process_result('error', 'errors', 1, 1)
  end

  def test_passing_test_exits_successfully
    assert_process_result('passing', 'failures', 0, 0)
  end

  def test_skipped_test_exits_successfully
    assert_process_result('skipped', 'skipped', 1, 0)
  end

  private

  def assert_process_result(scenario, category, count, exit_status)
    root = File.expand_path('../..', __dir__)
    stdout, stderr, status = Open3.capture3(
      { 'MT_NO_PLUGINS' => nil },
      RbConfig.ruby, '-Ilib', File.join(root, 'test/files/test_exit_status.rb'),
      '--name', "test_#{scenario}", '--heat-json', chdir: root
    )
    refute_empty stdout, "Child exited #{status.exitstatus}: #{stderr}"
    result = JSON.parse(stdout)

    assert_equal 1, result.fetch('statistics').fetch('total'), stderr
    assert_equal count, result.fetch('statistics').fetch(category), stdout
    assert_equal(exit_status.zero? ? 'passed' : 'failed', result.fetch('status'), stdout)
    assert_equal exit_status, status.exitstatus, "#{stdout}\n#{stderr}"
  end
end
