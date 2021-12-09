# frozen_string_literal: true

require 'test_helper'

class Minitest::Heat::ConfigurationTest < Minitest::Test
  def setup
  end

  def teardown
    Minitest::Heat.reset
  end

  def test_default_slow_thresholds
    issue = Minitest::Heat::Issue.new
    assert_equal Minitest::Heat::Issue::SLOW_THRESHOLDS[:slow], issue.slow_threshold
    assert_equal Minitest::Heat::Issue::SLOW_THRESHOLDS[:painful], issue.painfully_slow_threshold
  end

  def test_slow_thresholds_can_be_configured
    slow_threshold = 0.25
    painfully_slow_threshold = 0.75
    Minitest::Heat.configure do |config|
      config.slow_threshold = slow_threshold
      config.painfully_slow_threshold = painfully_slow_threshold
    end

    issue = Minitest::Heat::Issue.new
    assert_equal slow_threshold, issue.slow_threshold
    assert_equal painfully_slow_threshold, issue.painfully_slow_threshold
  end
end
