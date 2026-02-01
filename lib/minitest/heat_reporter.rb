# frozen_string_literal: true

require_relative 'heat'

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
                :timer,
                :results

    def initialize(io = $stdout, options = {})
      super()

      @options = options

      @timer =    Heat::Timer.new
      @results =  Heat::Results.new
      @output =   Heat::Output.new(io)
    end

    # Starts reporting on the run.
    def start
      timer.start!

      # A couple of blank lines to create some breathing room (skip for JSON output)
      return if json_output?

      output.newline
      output.newline
    end

    # About to start running a test. This allows a reporter to show that it is starting or that we
    # are in the middle of a test run. Parameters required by Minitest::AbstractReporter interface.
    def prerecord(_klass, _name); end

    # Records the data from a result.
    #
    # Minitest::Result source:
    #   https://github.com/seattlerb/minitest/blob/f4f57afaeb3a11bd0b86ab0757704cb78db96cf4/lib/minitest.rb#L504
    def record(result)
      # Convert a Minitest Result into an "issue" to more consistently expose the data needed to
      # adjust the failure output to the type of failure
      issue = Heat::Issue.from_result(result)

      # Note the number of assertions for the performance summary
      timer.increment_counts(issue.assertions)

      # Record the issue to show details later
      results.record(issue)

      # Show the marker (skip for JSON output)
      output.marker(issue.type) unless json_output?
    rescue StandardError => e
      display_exception_guidance(e)
    end

    def display_exception_guidance(exception)
      output.newline
      puts 'Sorry, but Minitest Heat encountered an exception recording an issue. Disabling Minitest Heat will get you back on track.'
      puts 'Please use the following exception details to submit an issue at https://github.com/garrettdimon/minitest-heat/issues'
      puts "#{exception.message}:"
      exception.backtrace.each do |line|
        puts "  #{line}"
      end
      output.newline
    end

    # Outputs the summary of the run.
    def report
      timer.stop!

      if json_output?
        output_json
      else
        output_text
      end
    end

    # Whether to output JSON instead of human-readable text
    #
    # @return [Boolean] true if --heat-json flag was passed
    def json_output? = options[:heat_json]

    # Did this run pass?
    def passed? = results.errors.empty? && results.failures.empty?

    private

    def output_json
      require 'json'
      output.stream.puts JSON.pretty_generate(json_results)
    end

    def json_results
      {
        version: '1.0',
        status: results.problems? ? 'failed' : 'passed',
        timestamp: Time.now.iso8601,
        statistics: results.statistics,
        timing: timer.to_h,
        heat_map: results.heat_map.to_h,
        issues: results.issues_with_problems.map(&:to_h)
      }
    end

    def output_text
      # The list of individual issues and their associated details
      output.issues_list(results)

      # Display a short summary of the total issue counts for each category as well as performance
      # details for the test suite as a whole
      output.compact_summary(results, timer)

      # If there were issues, shows a short heat map summary of which files and lines were the most
      # common sources of issues
      output.heat_map(results)

      output.newline
      output.newline
    end
  end
end
