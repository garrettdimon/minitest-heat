# frozen_string_literal: true

module IssueHelpers
  # Default test location for building issues.
  # Tests can override by setting @location in setup or passing test_location: explicitly.
  def default_test_location
    @location || [__FILE__, 1]
  end

  def build_issue(passed: false, error: false, skipped: false, execution_time: 0.001, backtrace: [], test_location: nil)
    ::Minitest::Heat::Issue.new(
      assertions: 1,
      message: 'Test message',
      backtrace: backtrace,
      test_location: test_location || default_test_location,
      test_class: 'TestClass',
      test_identifier: 'test_method',
      execution_time: execution_time,
      passed: passed,
      error: error,
      skipped: skipped
    )
  end

  def build_results
    ::Minitest::Heat::Results.new
  end

  def build_timer(test_count: 0, assertion_count: 0)
    timer = ::Minitest::Heat::Timer.new
    timer.start!
    test_count.times { timer.increment_counts(assertion_count) }
    timer.stop!
    timer
  end
end
