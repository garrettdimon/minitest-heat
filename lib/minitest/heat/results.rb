# frozen_string_literal: true

module Minitest
  module Heat
    # A collection of test failures
    class Results

      attr_reader :test_count,
                  :assertion_count,
                  :success_count,
                  :issues,
                  :start_time,
                  :stop_time

      def initialize
        @test_count = 0
        @assertion_count = 0
        @success_count = 0
        @issues = {
          error: [],
          broken: [],
          failure: [],
          skipped: [],
          painful: [],
          slow: []
        }
        @start_time = nil
        @stop_time = nil
      end

      def start_timer!
        @start_time = Minitest.clock_time
      end

      def stop_timer!
        @stop_time = Minitest.clock_time
      end

      def total_time
        delta = @stop_time - @start_time

        # Don't return 0
        delta.zero? ? 0.1 : delta
      end

      def tests_per_second
        (assertion_count / total_time).round(2)
      end

      def assertions_per_second
        (assertion_count / total_time).round(2)
      end

      def problems?
        errors? || brokens? || failures? || skips?
      end

      def errors
        issues.fetch(:error) { [] }
      end

      def brokens
        issues.fetch(:broken) { [] }
      end

      def failures
        issues.fetch(:failure) { [] }
      end

      def skips
        issues.fetch(:skipped) { [] }
      end

      def painfuls
        issues
          .fetch(:painful) { [] }
          .sort { |issue| issue.time }
          .reverse
          .take(5)
      end

      def slows
        issues
          .fetch(:slow) { [] }
          .sort { |issue| issue.time }
          .reverse
          .take(5)
      end

      def errors?
        errors.any?
      end

      def brokens?
        brokens.any?
      end

      def failures?
        failures.any?
      end

      def skips?
        skips.any?
      end

      def painfuls?
        painfuls.any?
      end

      def slows?
        slows.any?
      end

      def record(issue)
        @test_count += 1
        @assertion_count += issue.result.assertions
        @success_count += 1 if issue.result.passed?

        @issues[issue.type] ||= []
        @issues[issue.type] << issue
      end
    end
  end
end
