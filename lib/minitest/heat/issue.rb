# frozen_string_literal: true

require 'forwardable'

module Minitest
  module Heat
    # Wrapper for Result to provide a more natural-language approach to result details
    class Issue
      extend Forwardable

      SLOW_THRESHOLDS = {
        slow: 1.0,
        painful: 3.0
      }

      MARKERS = {
        success:  '·',
        slow:     '–',
        painful:  '—',
        broken:   'B',
        error:    'E',
        skipped:  'S',
        failure:  'F',
      }

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

      def short_location
        location.to_s.delete_prefix(Dir.pwd)
      end

      def to_hit
        [
          location.project_file.to_s,
          location.project_failure_line,
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
        elsif painful?
          :painful
        elsif slow?
          :slow
        else
          :success
        end
      end

      def hit?
        !passed? || slow?
      end

      def slow?
        time >= SLOW_THRESHOLDS[:slow]
      end

      def painful?
        time >= SLOW_THRESHOLDS[:painful]
      end

      def in_test?
        location.broken_test?
      end

      def in_source?
        location.proper_failure?
      end

      def test_class
        result.klass
      end

      def test_identifier
        result.name
      end

      def test_name
        test_identifier.delete_prefix('test_').gsub('_', ' ').capitalize
      end

      def exception
        failure.exception
      end

      def time
        result.time
      end

      def slowness
        "#{time.round(2)}s"
      end

      def label
        if error? && in_test?
          # When the exception came out of the test itself, that's a different kind of exception
          # that really only indicates there's a problem with the code in the test. It's kind of
          # between an error and a test.
          'Test Error'
        elsif error? || !passed?
          failure.result_label
        elsif slow?
          'Passed but Slow'
        else

        end
      end

      def marker
        MARKERS.fetch(type.to_sym)
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
