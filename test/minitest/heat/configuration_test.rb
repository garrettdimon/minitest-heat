# frozen_string_literal: true

require 'test_helper'

class Minitest::Heat::ConfigurationTest < Minitest::Test
  def setup
    Minitest::Heat.reset

    # Make the tests read a little less messy
    @defaults = Minitest::Heat::Configuration::DEFAULTS
    @config   = Minitest::Heat.configuration
  end

  def teardown
    Minitest::Heat.configure do |config|
      config.slow_threshold = 0.05
      config.painfully_slow_threshold = 0.1
    end
  end

  def test_default_slow_thresholds
    assert_equal @defaults[:slow_threshold], @config.slow_threshold
    assert_equal @defaults[:painfully_slow_threshold], @config.painfully_slow_threshold
  end

  def test_default_inherently_slow_paths
    assert_equal [], @config.inherently_slow_paths
  end

  def test_inherently_slow_paths_can_be_configured
    Minitest::Heat.configure do |config|
      config.inherently_slow_paths = ['test/system', 'test/integration']
    end

    assert_equal ['test/system', 'test/integration'], @config.inherently_slow_paths
  end

  def test_inherently_slow_path_matches_prefix
    @config.inherently_slow_paths = ['test/system']

    assert @config.inherently_slow_path?('test/system/login_test.rb')
  end

  def test_inherently_slow_path_does_not_match_other_paths
    @config.inherently_slow_paths = ['test/system']

    refute @config.inherently_slow_path?('test/models/user_test.rb')
  end

  def test_slow_thresholds_can_be_configured
    slow_threshold = @config.slow_threshold
    painfully_slow_threshold = @config.painfully_slow_threshold

    Minitest::Heat.configure do |config|
      config.slow_threshold += 1.0
      config.painfully_slow_threshold += 1.0
    end

    assert_equal (slow_threshold + 1.0), @config.slow_threshold
    assert_equal (painfully_slow_threshold + 1.0), @config.painfully_slow_threshold
  end
end
