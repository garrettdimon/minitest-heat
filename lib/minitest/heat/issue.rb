# frozen_string_literal: true

require 'forwardable'

module Minitest
  module Heat
    # Wrapper for Result to provide a more natural-language approach to result details
    class Issue
      extend Forwardable

      TYPES = %i[error broken failure skipped painful slow].freeze

      # # Long-term, these could be configurable so that people can determine their own thresholds of
      # # pain for slow tests
      # SLOW_THRESHOLDS = {
      #   slow: 1.0,
      #   painful: 3.0
      # }.freeze

      attr_reader :assertions,
                  :locations,
                  :message,
                  :test_class,
                  :test_identifier,
                  :execution_time,
                  :passed,
                  :error,
                  :skipped

      def_delegators :@locations, :backtrace, :test_definition_line, :test_failure_line

      # Extracts the necessary data from result.
      # @param result [Minitest::Result] the instance of Minitest::Result to examine
      #
      # @return [Issue] the instance of the issue to use for examining the result
      def self.from_result(result)
        # Not all results are failures, so we use the safe navigation operator
        exception = result.failure&.exception

        new(
          assertions: result.assertions,
          test_location: result.source_location,
          test_class: result.klass,
          test_identifier: result.name,
          execution_time: result.time,
          passed: result.passed?,
          error: result.error?,
          skipped: result.skipped?,
          message: exception&.message,
          backtrace: exception&.backtrace
        )
      end

      # Creates an instance of Issue. In general, the `from_result` approach will be more convenient
      #   for standard usage, but for lower-level purposes like testing, the initializer provides3
      #   more fine-grained control
      # @param assertions: 1 [Integer] the number of assertions in the result
      # @param message: nil [String] exception if there is one
      # @param backtrace: [] [Array<String>] the array of backtrace lines from an exception
      # @param test_location: nil [Array<String, Integer>] the locations identifier for a test
      # @param test_class: nil [String] the class name for the test result's containing class
      # @param test_identifier: nil [String] the name of the test
      # @param execution_time: nil [Float] the time it took to run the test
      # @param passed: false [Boolean] true if the test explicitly passed, false otherwise
      # @param error: false [Boolean] true if the test raised an exception
      # @param skipped: false [Boolean] true if the test was skipped
      #
      # @return [type] [description]
      def initialize(assertions: 1, test_location: ['Unrecognized Test File', 1], backtrace: [], execution_time: 0.0, message: nil, test_class: nil, test_identifier: nil, passed: false, error: false, skipped: false)
        @message = message

        @assertions = Integer(assertions)
        @locations = Locations.new(test_location, backtrace)

        @test_class = test_class
        @test_identifier = test_identifier
        @execution_time = Float(execution_time)

        @passed = passed
        @error = error
        @skipped = skipped
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
        elsif passed? && painful?
          :painful
        elsif passed? && slow?
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
        !passed? || slow? || painful?
      end

      # The number, in seconds, for a test to be considered "slow"
      #
      # @return [Float] number of seconds after which a test is considered slow
      def slow_threshold
        Minitest::Heat.configuration.slow_threshold
      end

      # The number, in seconds, for a test to be considered "painfully slow"
      #
      # @return [Float] number of seconds after which a test is considered painfully slow
      def painfully_slow_threshold
        Minitest::Heat.configuration.painfully_slow_threshold
      end

      # Determines if a test should be considered slow by comparing it to the low end definition of
      #   what is considered slow.
      #
      # @return [Boolean] true if the test took longer to run than `slow_threshold`
      def slow?
        execution_time >= slow_threshold && execution_time < painfully_slow_threshold
      end

      # Determines if a test should be considered painfully slow by comparing it to the high end
      #   definition of what is considered slow.
      #
      # @return [Boolean] true if the test took longer to run than `painfully_slow_threshold`
      def painful?
        execution_time >= painfully_slow_threshold
      end

      # Determines if the issue is an exception that was raised from directly within a test
      #   definition. In these cases, it's more likely to be a quick fix.
      #
      # @return [Boolean] true if the final locations of the stacktrace was a test file
      def in_test?
        locations.broken_test?
      end

      # Determines if the issue is an exception that was raised from directly within the project
      #   codebase.
      #
      # @return [Boolean] true if the final locations of the stacktrace was a file from the project
      #   (as opposed to a dependency or Ruby library)
      def in_source?
        locations.proper_failure?
      end

      # Was the result a pass? i.e. Skips aren't passes or failures. Slows are still passes. So this
      #   is purely a measure of whether the test explicitly passed all assertions
      #
      # @return [Boolean] false for errors, failures, or skips, true for passes (including slows)
      def passed?
        passed
      end

      # Was there an exception that triggered a failure?
      #
      # @return [Boolean] true if there's an exception
      def error?
        error
      end

      # Was the test skipped?
      #
      # @return [Boolean] true if the test was explicitly skipped, false otherwise
      def skipped?
        skipped
      end

      # The more nuanced detail of the failure. If it's an error, digs into the exception. Otherwise
      #   uses the message from the result
      #
      # @return [String] a more detailed explanation of the issue
      def summary
        # When there's an exception, use the first line from the exception message. Otherwise,  the
        #   message represents explanation for a test failure, and should be used in full
        error? ? first_line_of_exception_message : message
      end

      # Returns the first line of an exception message when the issue is from a proper exception
      #   failure since exception messages can be long and cumbersome.
      #
      # @return [String] the first line of the exception message
      def first_line_of_exception_message
        return '' if message.nil? || message.empty?

        text = message.split("\n")[0].to_s

        text.size > exception_message_limit ? "#{text[0..exception_message_limit]}..." : text
      end

      def exception_message_limit
        200
      end

      # Generates a hash representation for JSON serialization
      #
      # @return [Hash] issue data
      def to_h
        {
          type: type,
          test_class: test_class,
          test_name: test_identifier,
          execution_time: execution_time,
          assertions: assertions,
          message: message,
          test_location: locations.test_definition&.to_h,
          failure_location: failure_location_hash
        }
      end

      private

      def failure_location_hash
        location = locations.most_relevant
        return nil if location.nil?
        return nil if location == locations.test_definition

        location.to_h
      end
    end
  end
end
