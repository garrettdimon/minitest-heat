# frozen_string_literal: true

require 'test_helper'

class Minitest::Heat::ResultsTest < Minitest::Test
  def setup
    @results = ::Minitest::Heat::Results.new

    @source_filename = "#{Dir.pwd}/test/files/source.rb"
    @test_filename = "#{Dir.pwd}/test/minitest/heat/results_test.rb"
    @location = [@test_filename, 1]
    @source_backtrace = [
      "#{@source_filename}:1:in `method_name'",
      "#{@test_filename}:1:in `other_method_name'"
    ]
  end

  def test_initialization
    results = ::Minitest::Heat::Results.new

    assert_empty results.issues
    assert_instance_of Minitest::Heat::Map, results.heat_map
  end

  def test_record_stores_issues
    issue = build_issue(passed: true)
    @results.record(issue)

    assert_equal 1, @results.issues.length
  end

  def test_record_updates_heat_map_for_failures
    issue = build_issue(passed: false)
    @results.record(issue)

    refute_empty @results.heat_map.hits
  end

  def test_record_does_not_update_heat_map_for_successes
    # Use execution_time: 0.0 to ensure it's below slow_threshold and truly a success
    issue = build_issue(passed: true, execution_time: 0.0)
    @results.record(issue)

    assert_empty @results.heat_map.hits
  end

  def test_problems_returns_true_when_errors_exist
    @results.record(build_issue(error: true, backtrace: @source_backtrace))

    assert @results.problems?
  end

  def test_problems_returns_true_when_failures_exist
    @results.record(build_issue(passed: false))

    assert @results.problems?
  end

  def test_problems_returns_false_when_only_successes
    @results.record(build_issue(passed: true, execution_time: 0.0))

    refute @results.problems?
  end

  def test_problems_returns_false_when_only_skips
    @results.record(build_issue(skipped: true))

    refute @results.problems?
  end

  def test_errors_returns_only_error_issues
    @results.record(build_issue(error: true, backtrace: @source_backtrace))
    @results.record(build_issue(passed: false))
    @results.record(build_issue(passed: true, execution_time: 0.0))

    assert_equal 1, @results.errors.length
    assert_equal :error, @results.errors.first.type
  end

  def test_brokens_returns_only_broken_issues
    # Broken = error with test file first in backtrace
    test_backtrace = @source_backtrace.reverse
    @results.record(build_issue(error: true, backtrace: test_backtrace))
    @results.record(build_issue(passed: false))

    assert_equal 1, @results.brokens.length
    assert_equal :broken, @results.brokens.first.type
  end

  def test_failures_returns_only_failure_issues
    @results.record(build_issue(passed: false))
    @results.record(build_issue(passed: true, execution_time: 0.0))
    @results.record(build_issue(skipped: true))

    assert_equal 1, @results.failures.length
    assert_equal :failure, @results.failures.first.type
  end

  def test_skips_returns_only_skipped_issues
    @results.record(build_issue(skipped: true))
    @results.record(build_issue(passed: true, execution_time: 0.0))

    assert_equal 1, @results.skips.length
    assert_equal :skipped, @results.skips.first.type
  end

  def test_painfuls_returns_only_painful_issues_sorted_by_time
    painful_threshold = Minitest::Heat.configuration.painfully_slow_threshold
    @results.record(build_issue(passed: true, execution_time: painful_threshold + 1.0))
    @results.record(build_issue(passed: true, execution_time: painful_threshold + 2.0))
    @results.record(build_issue(passed: true, execution_time: 0.0001))

    assert_equal 2, @results.painfuls.length
    # Should be sorted by execution_time descending
    assert @results.painfuls.first.execution_time > @results.painfuls.last.execution_time
  end

  def test_slows_returns_only_slow_issues_sorted_by_time
    slow_threshold = Minitest::Heat.configuration.slow_threshold
    painful_threshold = Minitest::Heat.configuration.painfully_slow_threshold
    # Slow is between slow_threshold and painfully_slow_threshold
    @results.record(build_issue(passed: true, execution_time: slow_threshold))
    @results.record(build_issue(passed: true, execution_time: slow_threshold + 0.001))
    @results.record(build_issue(passed: true, execution_time: painful_threshold + 1.0)) # Too slow - painful
    @results.record(build_issue(passed: true, execution_time: 0.00001)) # Too fast - success

    assert_equal 2, @results.slows.length
    # Should be sorted by execution_time descending
    assert @results.slows.first.execution_time > @results.slows.last.execution_time
  end

  def test_statistics_returns_counts_by_type
    @results.record(build_issue(error: true, backtrace: @source_backtrace))
    @results.record(build_issue(passed: false))
    @results.record(build_issue(passed: false))
    @results.record(build_issue(skipped: true))
    @results.record(build_issue(passed: true, execution_time: 0.0))

    stats = @results.statistics

    assert_kind_of Hash, stats
    assert_equal 5, stats[:total]
    assert_equal 1, stats[:errors]
    assert_equal 2, stats[:failures]
    assert_equal 1, stats[:skipped]
  end

  def test_issues_with_problems_excludes_successes
    @results.record(build_issue(error: true, backtrace: @source_backtrace))
    @results.record(build_issue(passed: false))
    @results.record(build_issue(skipped: true))
    @results.record(build_issue(passed: true, execution_time: 0.0))

    problems = @results.issues_with_problems

    assert_equal 3, problems.length
    refute(problems.any? { |i| i.type == :success })
  end

  def test_to_h_returns_hash_with_statistics_and_heat_map
    @results.record(build_issue(error: true, backtrace: @source_backtrace))
    @results.record(build_issue(passed: false))

    hash = @results.to_h

    assert_kind_of Hash, hash
    assert hash.key?(:statistics)
    assert hash.key?(:heat_map)
    assert hash.key?(:issues)
    assert_kind_of Array, hash[:issues]
  end
end
