# frozen_string_literal: true

require 'forwardable'

module Minitest
  module Heat
    # Wrapper for Result to provide a more natural-language approach to result details
    class Issue
      extend Forwardable

      TYPES = %i[error broken failure skipped painful slow].freeze

      # Long-term, these could be configurable so that people can determine their own thresholds of
      # pain for slow tests
      SLOW_THRESHOLDS = {
        slow: 1.0,
        painful: 3.0
      }.freeze

      attr_reader :assertions,
                  :failure,
                  :location,
                  :test_class,
                  :test_identifier,
                  :execution_time,
                  :passed,
                  :error,
                  :skipped

      def_delegators :@location, :backtrace, :test_definition_line, :test_failure_line

      def self.from_result(result)
        new(
          assertions: result.assertions,
          failures: result.failures,
          location: result.source_location,
          test_class: result.klass,
          test_identifier: result.name,
          execution_time: result.time,
          passed: result.passed?,
          error: result.error?,
          skipped: result.skipped?,
        )
      end

      # Creates an instance of Issue. In general, the `from_result` approach will be more convenient
      #   for standard usage, but for lower-level purposes like testing, the initializer provides3
      #   more fine-grained control
      # @param assertions: 1 [Integer] the number of assertions in the result
      # @param failures: [] [Array<Exception>] failed assertions (roughly equivalent to exceptions)
      # @param location: nil [String] the location identifier for a test
      # @param test_class: nil [String] the class name for the test result's containing class
      # @param test_identifier: nil [String] the name of the test
      # @param execution_time: nil [Float] the time it took to run the test
      # @param passed: false [Boolean] true if the test explicitly passed, false otherwise
      # @param error: false [Boolean] true if the test raised an exception
      # @param skipped: false [Boolean] true if the test was skipped
      #
      # @return [type] [description]
      def initialize(assertions: 1, failures: [], location: nil, test_class: nil, test_identifier: nil, execution_time: nil, passed: false, error: false, skipped: false)
        @assertions = assertions
        @failure = failures.any? ? failures.first : nil
        @location = Location.new(location, @failure&.backtrace)

        @test_class = test_class
        @test_identifier = test_identifier
        @execution_time = execution_time

        @passed = passed
        @error = error
        @skipped = skipped
      end

      # Returns the primary location of the issue with the present working directory removed from
      #   the string for conciseness
      #
      # @return [String] the pathname for the file relative to the present working directory
      def short_location
        location.to_s.delete_prefix("#{Dir.pwd}/")
      end

      # Converts an issue to the key attributes for recording a 'hit'
      #
      # @return [Array] the filename, failure line, and issue type for categorizing a 'hit' to
      #   support generating the heat map
      def to_hit
        [
          location.project_file.to_s,
          Integer(location.project_failure_line),
          type
        ]
      end

      # Classifies different issue types so they can be categorized, organized, and prioritized.
      #   Primarily helps add some nuance to issue types. For example, an exception that arises from
      #   the project's source code is a genuine exception. But if the exception arose directly from
      #   the test, then it's more likely that there's just a simple syntax issue in the test.
      #   Similarly, the difference between a moderately slow test and a painfully slow test can be
      #   significant. A test that takes half a second is slow, but a test that takes 10 seconds is
      #   painfully slow and should get more attention.
      #
      # @return [Symbol] issue type for classifying issues and reporting
      def type # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        if error? && in_test?
          :broken
        elsif error?
          :error
        elsif skipped?
          :skipped
        elsif !passed?
          :failure
        elsif painful?
          :painful
        elsif slow?
          :slow
        else
          :success
        end
      end

      # Determines if the issue is a proper 'hit' which is anything that doesn't pass or is slow.
      #   (Because slow tests still pass and wouldn't otherwise be considered an issue.)
      #
      # @return [Boolean] true if the test did not pass or if it was slow
      def hit?
        !passed? || slow?
      end

      # Determines if a test should be considered slow by comparing it to the low end definition of
      #   what is considered slow.
      #
      # @return [Boolean] true if the test took longer to run than `SLOW_THRESHOLDS[:slow]`
      def slow?
        execution_time >= SLOW_THRESHOLDS[:slow]
      end

      # Determines if a test should be considered painfully slow by comparing it to the high end
      #   definition of what is considered slow.
      #
      # @return [Boolean] true if the test took longer to run than `SLOW_THRESHOLDS[:painful]`
      def painful?
        execution_time >= SLOW_THRESHOLDS[:painful]
      end

      # Determines if the issue is an exception that was raised from directly within a test
      #   definition. In these cases, it's more likely to be a quick fix.
      #
      # @return [Boolean] true if the final location of the stacktrace was a test file
      def in_test?
        location.broken_test?
      end

      # Determines if the issue is an exception that was raised from directly within the project
      #   codebase.
      #
      # @return [Boolean] true if the final location of the stacktrace was a file from the project
      #   (as opposed to a dependency or Ruby library)
      def in_source?
        location.proper_failure?
      end

      def test_name
        test_prefix = 'test_'

        if test_identifier.start_with?(test_prefix)
          test_identifier.delete_prefix(test_prefix).gsub('_', ' ')
        else
          test_identifier
        end
      end

      def exception
        failure.exception
      end

      def passed?
        passed
      end

      def error?
        error
      end

      def skipped?
        skipped
      end

      def slowness
        "#{execution_time.round(2)}s"
      end

      def label
        if error? && in_test?
          # When the exception came out of the test itself, that's a different kind of exception
          # that really only indicates there's a problem with the code in the test. It's kind of
          # between an error and a test.
          'Broken Test'
        elsif error? || !passed?
          failure.result_label
        elsif painful?
          'Passed but Very Slow'
        elsif slow?
          'Passed but Slow'
        end
      end

      def summary
        error? ? exception_parts[0] : exception.message
      end

      def freshest_file
        backtrace.recently_modified.first
      end

      private

      def exception_parts
        exception.message.split("\n")
      end
    end
  end
end
