# frozen_string_literal: true

require_relative "heat"

module Minitest
  # Custom minitest reporter to proactively identify likely culprits in test failures by focusing on
  #   the files and line numbers with the most issues and that were most recently modified. It also
  #   visually emphasizes results based on the most significant problems.
  #   1. Errors - Anything that raised an exception could have significant ripple effects.
  #   2. Failures - Assuming no exceptions, these are kind of important.
  #   -- Everything else...
  #   3. Coverage (If using Simplecov) - If things are passing but coverage isn't up to par
  #   4. Skips - Don't want to skip tests.
  #   5. Turtles (If everything good, but there's )
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
  class HeatReporter < AbstractReporter

    attr_reader :output,
                :options,
                :results,
                :heat_map

    def initialize(io = $stdout, options = {})
      @output = Heat::Output.new(io)
      @options = options

      @results = Heat::Results.new
      @heat_map = Heat::Map.new
    end

    # Starts reporting on the run.
    def start
      output.puts
      output.puts
      @results.start_timer!
    end

    # About to start running a test. This allows a reporter to show that it is starting or that we
    # are in the middle of a test run.
    def prerecord(klass, name)
    end

    # Records the data from a result.
    # Minitest::Result source:
    #   https://github.com/seattlerb/minitest/blob/f4f57afaeb3a11bd0b86ab0757704cb78db96cf4/lib/minitest.rb#L504
    def record(result)
      @results.count(result)
      output.marker(result.result_code)
    end

    # Outputs the summary of the run.
    def report
      @results.stop_timer!

      output.puts
      output.puts
      results.errors.each { |result| output.issue_details(result) }
      results.failures.each { |result| output.issue_details(result) }
      if results.errors.empty? && results.failures.empty?
        results.skips.each { |result| output.issue_details(result) }
      end
      output.compact_summary(results)
      output.puts
      output.puts
    end

    # Did this run pass?
    def passed?
    end
  end
end
