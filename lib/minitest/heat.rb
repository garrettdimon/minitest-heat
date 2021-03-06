# frozen_string_literal: true

require_relative 'heat/configuration'
require_relative 'heat/backtrace'
require_relative 'heat/hit'
require_relative 'heat/issue'
require_relative 'heat/location'
require_relative 'heat/locations'
require_relative 'heat/map'
require_relative 'heat/output'
require_relative 'heat/results'
require_relative 'heat/source'
require_relative 'heat/timer'
require_relative 'heat/version'

module Minitest
  # Custom Minitest reporter focused on generating output designed around efficiently identifying
  # issues and potential solutions
  # - Colorize the Output
  # - What files had the most errors?
  # - Show the most impacted areas first.
  # - Show lowest-level (most nested code) frist.
  #
  # Pulls from existing reporters:
  #   https://github.com/seattlerb/minitest/blob/master/lib/minitest.rb#L554
  #
  # Lots of insight from:
  #   http://www.monkeyandcrow.com/blog/reading_ruby_minitest_plugin_system/
  #
  # And a good example available at:
  #   https://github.com/adamsanderson/minitest-snail
  #
  # Pulls from minitest-color as well:
  #   https://github.com/teoljungberg/minitest-color/blob/master/lib/minitest/color_plugin.rb
  module Heat
    class << self
      attr_writer :configuration
    end

    def self.configuration
      @configuration ||= Configuration.new
    end

    def self.reset
      @configuration = Configuration.new
    end

    def self.configure
      yield(configuration)
    end
  end
end
