# frozen_string_literal: true

require 'test_helper'
require 'json'
require 'open3'
require 'rbconfig'

class Minitest::HeatEmptyRunTest < Minitest::Test
  def test_unmatched_exact_filter_exits_unsuccessfully
    assert_empty_run(['--name', 'test_nonexistent'], 1)
  end

  def test_unmatched_regexp_filter_exits_unsuccessfully
    assert_empty_run(['--name', '/nonexistent/'], 1)
  end

  def test_unmatched_filter_exits_unsuccessfully_with_text_output
    stdout, stderr, status = run_fixture(['--name', 'test_nonexistent'])

    assert_equal 1, status.exitstatus, stdout
    assert_includes stderr, 'Nothing ran for filter: test_nonexistent'
  end

  def test_excluded_unfiltered_run_remains_successful
    assert_empty_run(['--exclude', '/./'], 0)
  end

  def test_excluded_explicit_filter_exits_unsuccessfully
    assert_empty_run(['--name', 'test_passing', '--exclude', 'test_passing'], 1)
  end

  def test_minitest_six_include_filter
    skip 'Minitest 6 include option' if Minitest::VERSION.to_i < 6

    assert_empty_run(['--include', 'test_nonexistent'], 1)
    stdout, stderr, status = run_fixture(['--include', 'test_passing', '--heat-json'])
    assert status.success?, stderr
    assert_equal 1, JSON.parse(stdout).fetch('statistics').fetch('total')
  end

  private

  def assert_empty_run(arguments, exit_status)
    stdout, stderr, status = run_fixture([*arguments, '--heat-json'])
    refute_empty stdout, stderr
    result = JSON.parse(stdout)

    assert_equal 0, result.fetch('statistics').fetch('total'), stdout
    assert_equal exit_status, status.exitstatus, "#{stdout}\n#{stderr}"
    assert_equal(exit_status.zero? ? 'passed' : 'failed', result.fetch('status'))
    if exit_status.zero?
      refute_includes stderr, 'Nothing ran for filter:'
    else
      assert_includes stderr, 'Nothing ran for filter:'
    end
  end

  def run_fixture(arguments)
    root = File.expand_path('../..', __dir__)
    Open3.capture3(
      { 'MT_NO_PLUGINS' => nil }, RbConfig.ruby, '-Ilib',
      File.join(root, 'test/files/test_exit_status.rb'), *arguments, chdir: root
    )
  end
end
