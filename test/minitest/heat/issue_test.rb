# frozen_string_literal: true

require 'test_helper'

class Minitest::Heat::IssueTest < Minitest::Test
  def setup
    @source_filename = "#{Dir.pwd}/test/files/source.rb"
    @test_filename = __FILE__ # This is a test file, so it works

    @location = [@test_filename, 1]

    @source_backtrace = [
      "#{@source_filename}:1:in `method_name'",
      "#{@test_filename}:1:in `other_method_name'"
    ]

    # This creates a version with the test file first
    @test_backtrace = @source_backtrace.reverse
  end

  def test_full_initialization
    # Raise, rescue, and assign an exception instance to ensure the full context
    issue = ::Minitest::Heat::Issue.new(
      assertions: 1,
      message: '',
      backtrace: @source_backtrace,
      test_location: @location,
      test_class: 'Minitest::ClassName',
      test_identifier: 'Test Name',
      execution_time: 1.1,
      passed: false,
      error: false,
      skipped: false
    )
    refute_nil issue
  end

  def test_broken_test_issue
    issue = ::Minitest::Heat::Issue.new(
      backtrace: @test_backtrace,
      test_location: @location,
      error: true
    )

    assert_equal :broken, issue.type
    assert issue.hit?
    refute issue.passed?
    assert issue.in_test?
    refute issue.in_source?
  end

  def test_error_issue
    issue = ::Minitest::Heat::Issue.new(
      backtrace: @source_backtrace,
      test_location: @location,
      error: true
    )

    assert_equal :error, issue.type
    assert issue.error?
    refute issue.passed?
    assert issue.hit?
    refute issue.in_test?
    assert issue.in_source?
  end

  def test_skipped_issue
    issue = ::Minitest::Heat::Issue.new(skipped: true)

    assert_equal :skipped, issue.type
    assert issue.skipped?
    refute issue.passed?
    assert issue.hit?
  end

  def test_failure_issue
    issue = ::Minitest::Heat::Issue.new

    assert_equal :failure, issue.type
    refute issue.passed?
    assert issue.hit?
  end

  def test_painfully_slow_issue
    painful_time = Minitest::Heat.configuration.painfully_slow_threshold + 1.0

    issue = ::Minitest::Heat::Issue.new(
      execution_time: painful_time,
      passed: true
    )

    assert_equal :painful, issue.type
    assert issue.passed?
    assert issue.hit?
    refute issue.slow?
    assert issue.painful?
  end

  def test_slow_issue
    slow_time = Minitest::Heat.configuration.slow_threshold
    issue = ::Minitest::Heat::Issue.new(
      execution_time: slow_time,
      passed: true
    )

    assert_equal :slow, issue.type
    assert issue.passed?
    assert issue.hit?
    assert issue.slow?
    refute issue.painful?
  end

  def test_success_issue_is_not_a_hit
    issue = ::Minitest::Heat::Issue.new(passed: true)

    refute issue.hit?
    assert issue.passed?
  end
end
