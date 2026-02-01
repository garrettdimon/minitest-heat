# frozen_string_literal: true

require 'forwardable'

module Minitest
  module Heat
    # Kind of like an issue, but instead of focusing on a failing test, it covers all issues for a
    #   given file to build a heat map of the affected files and line numbers
    class Hit
      # Represents a single occurrence of an issue at a specific line
      Trace = Struct.new(:type, :line_number, :locations)

      # So we can sort hot spots by liklihood of being the most important spot to check out before
      #   trying to fix something. These are ranked based on the possibility they represent ripple
      #   effects where fixing one problem could potentially fix multiple other failures.
      #
      #   For example, if there's an exception in the file, start there. Broken code can't run. If a
      #   test is broken (i.e. raising an exception), that's a special sort of failure that would be
      #   misleading. It doesn't represent a proper failure, but rather a test that doesn't work.
      WEIGHTS = {
        error: 5,    # exceptions from source code have the highest likelihood of a ripple effect
        broken: 4,   # broken tests won't have ripple effects but can't help if they can't run
        failure: 3,  # failures are kind of the whole point, and they could have ripple effects
        skipped: 2,  # skips aren't failures, but they shouldn't go ignored
        painful: 1,  # slow tests aren't failures, but they shouldn't be ignored
        slow: 0
      }.freeze

      attr_reader :pathname, :issues, :lines

      # Creates an instance of a Hit for the given pathname. It must be the full pathname to
      #   uniquely identify the file or we could run into collisions that muddy the water and
      #   obscure which files had which errors on which line numbers
      # @param pathname [Pathname,String] the full pathname to the file
      #
      # @return [self]
      def initialize(pathname)
        @pathname = Pathname(pathname)
        @issues = {}
        @lines = {}
      end

      # Adds a record of a given issue type for the line number
      # @param type [Symbol] one of Issue::TYPES
      # @param line_number [Integer,String] the line number to record the issue on
      # @param backtrace: nil [Array<Location>] the project locations from the backtrace
      #
      # @return [void]
      def log(type, line_number, backtrace: [])
        line_number = Integer(line_number)
        issue_type = type.to_sym

        # Store issues by issue type with an array of line numbers
        @issues[issue_type] ||= []
        @issues[issue_type] << line_number

        # Store issues by line number with an array of Traces
        @lines[line_number.to_s] ||= []
        @lines[line_number.to_s] << Trace.new(issue_type, line_number, backtrace)
      end

      # Calcuates an approximate weight to serve as a proxy for which files are most likely to be
      #   the most problematic across the various issue types
      #
      # @return [Integer] the problem weight for the file
      def weight = issues.sum { |type, values| values.size * WEIGHTS.fetch(type, 0) }

      # The total issue count for the file across all issue types. Includes duplicates if they exist
      #
      # @return [Integer] the sum of the counts for all line numbers for all issue types
      def count = issues.sum { |_type, values| values.size }

      # The full set of unique line numbers across all issue types
      #
      # @return [Array<Integer>] the full set of unique offending line numbers for the hit
      def line_numbers = issues.values.flatten.uniq.sort

      # Generates a hash representation for JSON serialization
      #
      # @return [Hash] hit data with file, weight, and line details
      def to_h
        {
          file: relative_path,
          weight: weight,
          lines: lines_summary
        }
      end

      private

      def relative_path = pathname.to_s.delete_prefix("#{Dir.pwd}/")

      def lines_summary
        line_numbers.map do |line_num|
          traces = lines[line_num.to_s] || []
          {
            line: line_num,
            types: traces.map(&:type).uniq,
            count: traces.size
          }
        end
      end
    end
  end
end
