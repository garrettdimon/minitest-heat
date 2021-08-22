# frozen_string_literal: true

module Minitest
  module Heat
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
          failure: [],
          skip: [],
          turtle: []
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

      def issues?
        errors? || failures? || skips?
      end

      def errors
        issues.fetch(:error) { [] }
      end

      def failures
        issues.fetch(:failure) { [] }
      end

      def skips
        issues.fetch(:skips) { [] }
      end

      def turtles
        issues.fetch(:turtle) { [] }
      end

      def errors?
        errors.any?
      end

      def failures?
        failures.any?
      end

      def skips?
        skips.any?
      end

      def count(result)
        @test_count += 1
        @assertion_count += result.assertions
        @success_count += 1 if result.passed?
      end

      def record_issue(result)
        issue = Heat::Issue.new(result)

        @issues[issue.type] ||= []
        @issues[issue.type] << issue

        issue
      end
    end
  end
end
