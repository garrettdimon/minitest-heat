# frozen_string_literal: true

module Minitest
  module Heat
    # Convenience methods for determining the file and line number where the problem occurred.
    #   There are several layers of specificity to help make it easy to communicate the relative
    #   location of the failure:
    #   - 'final' represents the final line of the backtrace regardless of where it is
    #   - 'test_definition' represents where the test is defined
    #   - 'test_failure' represents the last line from the project's tests. It is further differentiated by
    #     the line where the test is defined and the actual line of code in the test that geneated
    #     the failure or exception
    #   - 'source_code' represents the last line from the project's source code
    #   - 'project' represents the last source line, but falls back to the last test line
    #   - 'most_relevant' represents the most specific file to investigate starting with the source
    #     code and then looking to the test code with final line of the backtrace as a fallback
    class Locations
      attr_reader :test_definition, :backtrace

      def initialize(test_definition_location, backtrace = [])
        test_definition_pathname, test_definition_line_number = test_definition_location
        @test_definition          = ::Minitest::Heat::Location.new(pathname: test_definition_pathname, line_number: test_definition_line_number)

        @backtrace = Backtrace.new(backtrace)
      end

      # Prints the pathname and line number of the location most likely to be the source of the
      #   test failure
      #
      # @return [String] ex. 'path/to/file.rb:12'
      def to_s
        "#{most_relevant.absolute_filename}:#{most_relevant.line_number}"
      end

      # Knows if the failure is contained within the test. For example, if there's bad code in a
      #   test, and it raises an exception, then it's really a broken test rather than a proper
      #   faiure.
      #
      # @return [Boolean] true if final file in the backtrace is the same as the test location file
      def broken_test?
        !test_failure.nil? && test_failure == final
      end

      # Knows if the failure occurred in the actual project source code—as opposed to the test or
      #   an external piece of code like a gem.
      #
      # @return [Boolean] true if there's a non-test project file in the stacktrace but it's not
      #   a result of a broken test
      def proper_failure?
        !source_code.nil? && !broken_test?
      end

      # The file most likely to be the source of the underlying problem. Often, the most recent
      #   backtrace files will be a gem or external library that's failing indirectly as a result
      #   of a problem with local source code (not always, but frequently). In that case, the best
      #   first place to focus is on the code you control.
      #
      # @return [Array] file and line number of the most likely source of the problem
      def most_relevant
        [
          source_code,
          test_failure,
          final
        ].compact.first
      end

      def freshest
        backtrace.recently_modified_locations.first
      end

      # Returns the final test location based on the backtrace if present. Otherwise falls back to
      #   the test location which represents the test definition. The `test_definition` attribute
      #   provides the location of where the test is defined. `test_failure` represents the actual
      #   line from within the test where the problem occurred
      #
      # @return [Location] the final location from the test files
      def test_failure
        backtrace.test_locations.any? ? backtrace.test_locations.first : test_definition
      end

      # Returns the final source code location based on the backtrace
      #
      # @return [Location] the final location from the source code files
      def source_code
        backtrace.source_code_locations.first
      end

      # Returns the final project location based on the backtrace if present. Otherwise falls back
      #   to the test location which represents the test definition.
      #
      # @return [Location] the final location from the project files
      def project
        backtrace.project_locations.any? ? backtrace.project_locations.first : test_definition
      end

      # The line number from within the `test_file` test definition where the failure occurred
      #
      # @return [Location] the last location from the backtrace or the test location if a backtrace
      #   was not passed to the initializer
      def final
        backtrace.locations.any? ? backtrace.locations.first : test_definition
      end
    end
  end
end
