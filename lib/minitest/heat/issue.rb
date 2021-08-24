# frozen_string_literal: true

require 'forwardable'

module Minitest
  module Heat
    # Wrapper for Result to provide a more natural-language approach to result details
    class Issue
      extend Forwardable

      SLOW_THRESHOLD = 0.05

      SHARED_SYMBOLS = {
        spacer: ' · ',
        arrow: ' > '
      }.freeze

      attr_reader :result, :location, :failure

      def_delegators :@result, :passed?, :error?, :skipped?
      def_delegators :@location, :backtrace

      def initialize(result)
        @result = result

        @failure = result.failures.any? ? result.failures.first : nil
        @location = Location.new(result.source_location, @failure&.backtrace)
      end

      def to_hit
        [
          location.source_file,
          location.source_failure_line,
          type
        ]
      end

      def spacer
        SHARED_SYMBOLS[:spacer]
      end

      def arrow
        SHARED_SYMBOLS[:arrow]
      end

      def type # rubocop:disable Metrics/MethodLength
        if error? && in_test?
          :broken
        elsif error?
          :error
        elsif skipped?
          :skipped
        elsif !passed?
          :failure
        elsif turtle?
          :turtle
        else
          :success
        end
      end

      def turtle?
        time > SLOW_THRESHOLD
      end

      def in_test?
        location.failure_in_test?
      end

      def in_source?
        location.failure_in_source?
      end

      def test_class
        result.klass.delete_prefix('Minitest::')
      end

      def test_name
        result.name.delete_prefix('test_').gsub('_', ' ').capitalize
      end

      def exception
        failure.exception
      end

      def time
        result.time
      end

      def label
        if error? && in_test?
          # When the exception came out of the test itself, that's a different kind of exception
          # that really only indicates there's a problem with the code in the test. It's kind of
          # between an error and a test.
          'Broken Test'
        elsif error? || !passed?
          failure.result_label
        elsif turtle?
          'Passed but Slow'
        else

        end
      end

      def marker
        case type
        when :broken then  'B'
        when :error then   'E'
        when :skipped then 'S'
        when :failure then 'F'
        when :turtle then  'T'
        else               '.'
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
