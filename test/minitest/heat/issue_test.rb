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

  def test_slow_issue_in_inherently_slow_path_is_success
    Minitest::Heat.configure do |config|
      config.inherently_slow_paths = ['test/files/system']
    end

    slow_time = Minitest::Heat.configuration.slow_threshold
    system_test = "#{Dir.pwd}/test/files/system/example_test.rb"

    issue = ::Minitest::Heat::Issue.new(
      execution_time: slow_time,
      test_location: [system_test, 1],
      passed: true
    )

    assert_equal :success, issue.type
  ensure
    Minitest::Heat.configure do |config|
      config.inherently_slow_paths = []
    end
  end

  def test_painful_issue_in_inherently_slow_path_is_success
    Minitest::Heat.configure do |config|
      config.inherently_slow_paths = ['test/files/system']
    end

    painful_time = Minitest::Heat.configuration.painfully_slow_threshold + 1.0
    system_test = "#{Dir.pwd}/test/files/system/example_test.rb"

    issue = ::Minitest::Heat::Issue.new(
      execution_time: painful_time,
      test_location: [system_test, 1],
      passed: true
    )

    assert_equal :success, issue.type
  ensure
    Minitest::Heat.configure do |config|
      config.inherently_slow_paths = []
    end
  end

  def test_to_h_returns_hash_with_issue_data
    issue = ::Minitest::Heat::Issue.new(
      assertions: 3,
      message: 'Expected true, got false',
      backtrace: @source_backtrace,
      test_location: @location,
      test_class: 'UserTest',
      test_identifier: 'test_validates_email',
      execution_time: 0.05,
      passed: false,
      error: false,
      skipped: false
    )

    hash = issue.to_h

    assert_kind_of Hash, hash
    assert_equal :failure, hash[:type]
    assert_equal 'UserTest', hash[:test_class]
    assert_equal 'test_validates_email', hash[:test_name]
    assert_equal 0.05, hash[:execution_time]
    assert_equal 3, hash[:assertions]
    assert_equal 'Expected true, got false', hash[:message]
  end

  def test_to_h_includes_location_data
    issue = ::Minitest::Heat::Issue.new(
      backtrace: @source_backtrace,
      test_location: @location,
      test_class: 'UserTest',
      test_identifier: 'test_example'
    )

    hash = issue.to_h

    assert_kind_of Hash, hash[:test_location]
    assert hash[:test_location].key?(:file)
    assert hash[:test_location].key?(:line)
  end

  def test_to_h_with_error_includes_failure_location
    issue = ::Minitest::Heat::Issue.new(
      backtrace: @source_backtrace,
      test_location: @location,
      error: true
    )

    hash = issue.to_h

    assert_kind_of Hash, hash[:failure_location]
  end
end
