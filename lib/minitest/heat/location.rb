# frozen_string_literal: true

module Minitest
  module Heat
    # Convenience methods for determining the file and line number where the problem occurred.
    #   There are several layers of specificity to help make it easy to communicate the relative
    #   location of the failure:
    #   - 'final' represents the final line of the backtrace regardless of where it is
    #   - 'test' represents the last line from the project's tests. It is further differentiated by
    #     the line where the test is defined and the actual line of code in the test that geneated
    #     the failure or exception
    #   - 'source_code' represents the last line from the project's source code
    #   - 'project' represents the last source line, but falls back to the last test line
    #   - 'most_relevant' represents the most specific file to investigate starting with the source
    #     code and then looking to the test code with final line of the backtrace as a fallback
    class Location
      attr_reader :test_location, :backtrace

      def initialize(test_location, backtrace = [])
        @test_location = test_location
        @backtrace = Backtrace.new(backtrace)
      end

      # Prints the pathname and line number of the location most likely to be the source of the
      #   test failure
      #
      # @return [String] ex. 'path/to/file.rb:12'
      def to_s
        "#{most_relevant_file}:#{most_relevant_failure_line}"
      end

      # Knows if the failure is contained within the test. For example, if there's bad code in a
      #   test, and it raises an exception, then it's really a broken test rather than a proper
      #   faiure.
      #
      # @return [Boolean] true if most relevant file is the same as the test location file
      def broken_test?
        !test_file.nil? && test_file == most_relevant_file
      end

      # Knows if the failure occurred in the actual project source code—as opposed to the test or
      #   an external piece of code like a gem.
      #
      # @return [Boolean] true if there's a non-test project file in the stacktrace but it's not
      #   a result of a broken test
      def proper_failure?
        !source_code_file.nil? && !broken_test?
      end

      # The file most likely to be the source of the underlying problem. Often, the most recent
      #   backtrace files will be a gem or external library that's failing indirectly as a result
      #   of a problem with local source code (not always, but frequently). In that case, the best
      #   first place to focus is on the code you control.
      #
      # @return [String] the relative path to the file from the project root
      def most_relevant_file
        reduced_path(most_relevant_location[0])
      end

      # The line number of the `most_relevant_file` where the failure originated
      #
      # @return [Integer] line number
      def most_relevant_failure_line
        most_relevant_location[1]
      end

      # The final location of the stacktrace regardless of whether it's from within the project
      #
      # @return [String] the relative path to the file from the project root
      def final_file
        final_location[0]
      end

      # The line number of the `final_file` where the failure originated
      #
      # @return [Integer] line number
      def final_failure_line
        final_location[1]
      end

      # The final location of the stacktrace regardless of whether it's from within the project
      #
      # @return [String] the relative path to the file from the project root
      def project_file
        source_code_file || test_file
      end

      # The line number of the `project_file` where the failure originated
      #
      # @return [Integer] line number
      def project_failure_line
        source_code_failure_line || test_failure_line
      end

      # The final location from the stacktrace that is within the project directory
      #
      # @return [String, nil] the relative path to the file from the project root
      def source_code_file
        return nil unless backtrace.source_code_lines.any?

        reduced_path(backtrace.final_source_code_location.to_file)
      end

      # The line number of the `source_code_file` where the failure originated
      #
      # @return [Integer] line number
      def source_code_failure_line
        return nil unless backtrace.source_code_lines.any?

        backtrace.final_source_code_location.number
      end

      # The final location from the stacktrace that is within the project's test directory
      #
      # @return [String, nil] the relative path to the file from the project root
      def test_file
        reduced_path(test_location[0])
      end

      # The line number of the `test_file` where the test is defined
      #
      # @return [Integer] line number
      def test_definition_line
        test_location[1].to_s
      end

      # The line number from within the `test_file` test definition where the failure occurred
      #
      # @return [Integer] line number
      def test_failure_line
        backtrace.final_test_location.number
      end

      private

      # The line number from within the `test_file` test definition where the failure occurred
      #
      # @return [Location] the last location from the backtrace or the test location if a backtrace
      #   was not passed to the initializer
      def final_location
        backtrace? ? backtrace.final_location : test_location
      end

      # The file most likely to be the source of the underlying problem. Often, the most recent
      #   backtrace files will be a gem or external library that's failing indirectly as a result
      #   of a problem with local source code (not always, but frequently). In that case, the best
      #   first place to focus is on the code you control.
      #
      # @return [Array] file and line number of the most likely source of the problem
      def most_relevant_location
        [
          source_code_location,
          test_location,
          final_location
        ].compact.first
      end

      def source_code_location
        backtrace.final_source_code_location
      end

      def backtrace?
        backtrace.parsed_lines.any?
      end

      def reduced_path(path)
        path.delete_prefix(Dir.pwd)
      end
    end
  end
end


