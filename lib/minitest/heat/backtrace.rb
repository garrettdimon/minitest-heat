# frozen_string_literal: true

require_relative 'backtrace/line'

module Minitest
  module Heat
    # Wrapper for separating backtrace into component parts
    class Backtrace
      attr_reader :raw_backtrace

      # Creates a more flexible backtrace data structure by parsing the lines of the backtrace to
      #   extract individual elements for investigating the offending files and line numbers
      # @param raw_backtrace [Array] the array of lines from the backtrace
      #
      # @return [self]
      def initialize(raw_backtrace)
        @raw_backtrace = Array(raw_backtrace)
      end

      # Determines if the raw backtrace has values in it
      #
      # @return [Boolean] true if there's no backtrace or it's empty
      def empty?
        raw_backtrace.empty?
      end

      # The final location exposed in the backtrace. Could be a line from the project or from a
      #   dependency or the Ruby core libraries
      #
      # @return [Line] the final location from the backtrace parsed as a Backtrace::Line
      def final_location
        parsed_entries.first
      end

      # The final location from within the project exposed in the backtrace. Could be test files or
      #   source code files
      #
      # @return [Line] the final project location from the backtrace parsed as a Backtrace::Line
      def final_project_location
        project_entries.first
      end

      # The most recently modified location from within the project
      #
      # @return [Line] the most recently modified project location from the backtrace parsed as a
      #   Backtrace::Line
      def freshest_project_location
        recently_modified_entries.first
      end

      # The final location from within the project source code (i.e. excluding tests)
      #
      # @return [Line] the final source code location from the backtrace parsed as a Backtrace::Line
      def final_source_code_location
        source_code_entries.first
      end

      # The second-to-last project location in the backtrace. When something goes wrong in
      #   multiple locations, but they all lead to the final source location, the preceding source
      #   code location is often helpful for discerning the pattern.
      #
      # @return [Line] the second-to-last source code location from the backtrace parsed as a
      #   Backtrace::Line
      def preceding_location
        project_entries.second
      end

      # The final location from within the project's tests (i.e. excluding source code)
      #
      # @return [Line] the final test location from the backtrace parsed as a Backtrace::Line
      def final_test_location
        test_entries.first
      end

      # All entries from the backtrace that are files within the project
      #
      # @return [Line] the backtrace lines from within the project parsed as Backtrace::Line's
      def project_entries
        @project_entries ||= parsed_entries.select { |entry| entry.path.to_s.include?(Dir.pwd) }
      end

      # All entries from the backtrace within the project and sorted with the most recently modified
      #   files at the beginning
      #
      # @return [Line] the sorted backtrace lines from the project parsed as Backtrace::Line's
      def recently_modified_entries
        @recently_modified_entries ||= project_entries.sort_by(&:mtime).reverse
      end

      # All entries from the backtrace within the project tests
      #
      # @return [Line] the backtrace lines from within the project tests parsed as Backtrace::Line's
      def test_entries
        @test_entries ||= project_entries.select(&:test_file?)
      end

      # All source code entries from the backtrace (i.e. excluding tests)
      #
      # @return [Line] the backtrace lines from within the source code parsed as Backtrace::Line's
      def source_code_entries
        @source_code_entries ||= project_entries - test_entries
      end

      # All lines of the backtrace converted to Backtrace::Line's
      #
      # @return [Line] the full set of backtrace lines parsed as Backtrace::Line instances
      def parsed_entries
        return [] if raw_backtrace.nil?

        @parsed_entries ||= raw_backtrace.map { |entry| Backtrace::Line.parse_backtrace(entry) }
      end
    end
  end
end
