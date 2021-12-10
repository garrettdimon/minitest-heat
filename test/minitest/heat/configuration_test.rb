# frozen_string_literal: true

require 'test_helper'

class Minitest::Heat::ConfigurationTest < Minitest::Test
  def setup
    Minitest::Heat.reset

    # Make the tests read a little less messy
    @defaults = Minitest::Heat::Configuration::DEFAULTS
    @config   = Minitest::Heat.configuration
  end

  def test_default_slow_thresholds
    assert_equal @defaults[:slow_threshold], @config.slow_threshold
    assert_equal @defaults[:painfully_slow_threshold], @config.painfully_slow_threshold
  end

  def test_slow_thresholds_can_be_configured
    slow_threshold = @config.slow_threshold
    painfully_slow_threshold = @config.painfully_slow_threshold

    # Change the settings to verify they get set appropriately
    Minitest::Heat.configure do |config|
      config.slow_threshold += 1.0
      config.painfully_slow_threshold += 1.0
    end

    assert_equal (slow_threshold + 1.0), @config.slow_threshold
    assert_equal (painfully_slow_threshold + 1.0), @config.painfully_slow_threshold

    # Return the settings to the previous values for the rest of the tests
    Minitest::Heat.configure do |config|
      config.slow_threshold -= 1.0
      config.painfully_slow_threshold -= 1.0
    end
  end
end
