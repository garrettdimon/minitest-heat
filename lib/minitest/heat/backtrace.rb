# frozen_string_literal: true

require_relative 'backtrace/line_parser'

module Minitest
  module Heat
    # Wrapper for separating backtrace into component parts
    class Backtrace
      attr_reader :raw_backtrace

      # Creates a more flexible backtrace data structure by parsing the lines of the backtrace to
      #   extract specific subsets of lines for investigating the offending files and line numbers
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

      # All lines of the backtrace converted to Backtrace::LineParser's
      #
      # @return [Line] the full set of backtrace lines parsed as Backtrace::LineParser instances
      def locations
        return [] if raw_backtrace.nil?

        @locations ||= raw_backtrace.map { |entry| Backtrace::LineParser.read(entry) }
      end

      # All entries from the backtrace within the project and sorted with the most recently modified
      #   files at the beginning
      #
      # @return [Line] the sorted backtrace lines from the project parsed as Backtrace::LineParser's
      def recently_modified_locations
        @recently_modified_locations ||= project_locations.sort_by(&:mtime).reverse
      end

      # All entries from the backtrace that are files within the project
      #
      # @return [Line] the backtrace lines from within the project parsed as Backtrace::LineParser's
      def project_locations
        @project_locations ||= locations.select(&:project_file?)
      end

      # All entries from the backtrace within the project tests
      #
      # @return [Line] the backtrace lines from within the project tests parsed as Backtrace::LineParser's
      def test_locations
        @test_locations ||= project_locations.select(&:test_file?)
      end

      # All source code entries from the backtrace (i.e. excluding tests)
      #
      # @return [Line] the backtrace lines from within the source code parsed as Backtrace::LineParser's
      def source_code_locations
        @source_code_locations ||= project_locations.select(&:source_code_file?)
      end
    end
  end
end
