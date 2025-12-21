# frozen_string_literal: true

require 'test_helper'

class Minitest::Heat::TimerTest < Minitest::Test
  def setup
    @timer = ::Minitest::Heat::Timer.new
  end

  def test_starting_timer
    assert_nil @timer.start_time
    @timer.start!
    refute_nil @timer.start_time
  end

  def test_stopping_timer
    assert_nil @timer.stop_time
    @timer.stop!
    refute_nil @timer.stop_time
  end

  def test_total_time
    @timer.start!
    @timer.stop!

    # total_time is stop_time - start_time, should be a small positive number
    assert_operator @timer.total_time, :>=, 0
    assert_operator @timer.total_time, :<, 1 # Should complete in under 1 second
  end

  def test_updating_counts
    assert_equal 0, @timer.test_count
    assert_equal 0, @timer.assertion_count
    @timer.increment_counts(3)
    assert_equal 1, @timer.test_count
    assert_equal 3, @timer.assertion_count
  end

  def test_tests_per_second
    assertion_count = 1
    @timer.start!
    @timer.increment_counts(assertion_count)
    @timer.stop!

    # 1 assertion and 1 test, so the rates should be equal
    assert_equal @timer.tests_per_second, @timer.assertions_per_second

    expected_rate = (1 / @timer.total_time).round(2)
    assert_equal expected_rate, @timer.tests_per_second
  end

  def test_assertions_per_second
    assertion_count = 3
    @timer.start!
    @timer.increment_counts(assertion_count)
    @timer.stop!

    # 3 assertions but 1 test, so the rates should be different
    refute_equal @timer.tests_per_second, @timer.assertions_per_second

    expected_rate = (assertion_count / @timer.total_time).round(2)
    assert_equal expected_rate, @timer.assertions_per_second
  end
end
