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
  #   5. Slows (If everything good, but there's )
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
                :map

    def initialize(io = $stdout, options = {})
      @output = Heat::Output.new(io)
      @options = options

      @results = Heat::Results.new
      @map = Heat::Map.new
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
      if !result.passed? || result.time > ::Minitest::Heat::Issue::SLOW_THRESHOLD
        issue = @results.record_issue(result)
        @map.add(*issue.to_hit)
        output.marker(issue.marker)
      else
        output.marker(result.result_code)
      end
    end

    # Outputs the summary of the run.
    def report
      @results.stop_timer!

      output.newline
      output.newline

      # Issues start with the least critical and go up to the most critical so that the most
      #   pressing issues are displayed at the bottom of the report in order to reduce scrolling.
      #   This way, as you fix issues, the list gets shorter, and eventually the least critical
      #   issues will be displayed without scrolling once more problematic issues are resolved.
      if results.failures.empty? && results.brokens.empty? && results.errors.empty?
        results.slows.each { |issue| output.issue_details(issue) }
        results.skips.each { |issue| output.issue_details(issue) }
      end

      results.failures.each { |issue| output.issue_details(issue) }
      results.brokens.each { |issue| output.issue_details(issue) }
      results.errors.each { |issue| output.issue_details(issue) }

      output.compact_summary(results)

      output.heat_map(map)
    end

    # Did this run pass?
    def passed?
      results.errors.empty? && results.failures.empty?
    end
  end
end
