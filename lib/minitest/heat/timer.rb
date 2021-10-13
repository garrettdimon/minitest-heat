# frozen_string_literal: true

module Minitest
  module Heat
    # Provides a timer to keep track of the full test suite duration and provide convenient methods
    #   for calculating tests/second and assertions/second
    class Timer
      attr_reader :test_count, :assertion_count, :start_time, :stop_time

      # Creates an instance of a timer to be used for the duration of a test suite run
      #
      # @return [self]
      def initialize
        @test_count = 0
        @assertion_count = 0

        @start_time = nil
        @stop_time = nil
      end

      # Records the start time for the full test suite using `Minitest.clock_time`
      #
      # @return [Float] the Minitest.clock_time
      def start!
        @start_time = Minitest.clock_time
      end

      # Records the stop time for the full test suite using `Minitest.clock_time`
      #
      # @return [Float] the Minitest.clock_time
      def stop!
        @stop_time = Minitest.clock_time
      end

      # Calculates the total time take for the full test suite to run while ensuring it never
      #   returns a zero that would be problematic as a denomitor in calculating average times
      #
      # @return [Float] the clocktime duration of the test suite run in seconds
      def total_time
        # Don't return 0. The time can end up being 0 for a new or realy fast test suite, and
        # dividing by 0 doesn't go well when determining average time, so this ensures it uses a
        # close-enough-but-not-zero value.
        delta.zero? ? 0.01 : delta
      end

      # Records the test and assertion counts for a given test outcome
      # @param count [Integer] the number of assertions from the test
      #
      # @return [void]
      def increment_counts(count)
        @test_count += 1
        @assertion_count += count
      end

      # Provides a nice rounded answer for about how many tests were completed per second
      #
      # @return [Float] the average number of tests completed per second
      def tests_per_second
        (test_count / total_time).round(2)
      end

      # Provides a nice rounded answer for about how many assertions were completed per second
      #
      # @return [Float] the average number of assertions completed per second
      def assertions_per_second
        (assertion_count / total_time).round(2)
      end

      private

      # The total time the test suite was running.
      #
      # @return [Float] the time in seconds elapsed between starting the timer and stopping it
      def delta
        return 0 unless start_time && stop_time

        stop_time - start_time
      end
    end
  end
end
