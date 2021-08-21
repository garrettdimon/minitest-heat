# frozen_string_literal: true

require 'forwardable'

module Minitest
  module Heat
    # Wrapper for Result to provide a more natural-language approach to result details
    class Issue
      extend Forwardable

      attr_reader :result, :location, :failure

      def_delegators :@result, :passed?, :error?, :skipped?
      def_delegators :@location, :backtrace

      def initialize(result)
        @result = result
        @failure = result.failures.first
        @location = Location.new(result.source_location, @failure.backtrace)
      end

      def self.raise_example_error_from_issue
        Location.raise_example_error_in_location
      end

      def formatter
        if error?
          Formatters::Error.new
        elsif skipped?
          Formatters::Skip.new
        elsif !passed?
          Formatters::Failure.new
        elsif turtle?
          Formatters::Turtle.new
        else
          raise 'No Matching Formatter'
        end
      end

      def turtle?
        time > Results::SLOW_THRESHOLD
      end

      def in_test?
        location.failure_in_test?
      end

      def in_source?
        location.failure_in_source?
      end

      def relevant_lines_of_code
        filename = File.path(Pathname.new("#{Dir.pwd}#{location.source_file}"))
        file = File.new(filename, "r")
        lines = file.each_line.to_a

        line_number = Integer(location.source_failure_line)
        line_numbers = [line_number - 1, line_number, line_number + 1]

        max_line_number_length = line_numbers.map(&:to_s).map(&:length).max

        [
          "#{line_numbers[0].to_s.rjust(max_line_number_length)}: #{lines[line_numbers[0] - 1]}",
          "#{line_numbers[1].to_s.rjust(max_line_number_length)}: #{lines[line_numbers[1] - 1]}",
          "#{line_numbers[2].to_s.rjust(max_line_number_length)}: #{lines[line_numbers[2] - 1]}",
        ]
      end

      def test_class
        result.klass.delete_prefix('Minitest::')
      end

      def test_name
        "#{result.name.delete_prefix('test_').gsub('_', ' ').capitalize}"
      end

      def exception
        failure.exception
      end

      def time
        result.time
      end

      def label
        failure.result_label
      end

      def marker
        failure.result_code
      end

      def summary
        error? ? exception_parts[0] : exception.message
      end

      def freshest_file
        backtrace.recently_modified.first
      end

      def trace
        location.backtrace.project.take(3).map do |line|
          path = reduced_path("#{line[:path]}/#{line[:file]}")

          "#{path}:#{line[:line]} - `#{line[:method]}`"
        end
      end

      private

      def exception_parts
        exception.message.split("\n")
      end
    end
  end
end
