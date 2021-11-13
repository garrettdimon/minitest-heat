# frozen_string_literal: true

require 'forwardable'

module Minitest
  module Heat
    class Backtrace
      # Represents a line from a backtrace to provide more convenient access to information about
      #   the relevant file and line number for displaying in test results
      class LineParser
        attr_accessor :pathname, :number, :container
        alias line_number number

        # Creates an instance of a line number reference
        # @param pathname: [Pathname, String] the full pathname to the file
        # @param number: [Integer, String] the line number in question
        # @param container: nil [String] the containing method or block for the line of code
        #
        # @return [self]
        def initialize(pathname:, number:, container: nil)
          @pathname = Pathname(pathname)
          @number = number.to_i
          @container = container.to_s
        end

        # Parses a line from a backtrace in order to convert it to usable components
        def self.parse_backtrace(raw_text)
          raw_pathname, raw_line_number, raw_container = raw_text.split(':')
          raw_container = raw_container.delete_prefix('in `').delete_suffix("'")

          new(pathname: raw_pathname, number: raw_line_number, container: raw_container)
        end

        # Generates a formatted string describing the line of code similar to the original backtrace
        #
        # @return [String] a consistently-formatted, human-readable string about the line of code
        def to_s
          "#{location} in `#{container}`"
        end

        # A safe interface to getting a string representing the path portion of the file
        #
        # @return [String] either the path/directory portion of the file name or '(Unrecognized File)'
        #   if the offending file can't be found for some reason
        def path
          pathname.exist? ? pathname.dirname : UNRECOGNIZED
        end

        # A safe interface for getting a string representing the filename portion of the file
        #
        # @return [String] either the filename portion of the file or '(Unrecognized File)'
        #   if the offending file can't be found for some reason
        def file
          pathname.exist? ? pathname.basename : UNRECOGNIZED
        end

        # A safe interface to getting the last modified time for the file in question
        #
        # @return [Time] the timestamp for when the file in question was last modified or `Time.at(0)`
        #   if the offending file can't be found for some reason
        def mtime
          pathname.exist? ? pathname.mtime : UNKNOWN_MODIFICATION_TIME
        end

        # A safe interface to getting the number of seconds since the file was modified
        #
        # @return [Integer] the number of seconds since the file was modified or `-1` if the offending
        #   file can't be found for some reason
        def age_in_seconds
          pathname.exist? ? seconds_ago : UNKNOWN_MODIFICATION_SECONDS
        end

        # A convenient method for getting the full location identifier using the full pathname and
        #   line number separated by a `:`
        #
        # @return [String] the full pathname and line number
        def location
          "#{pathname}:#{number}"
        end

        # A convenient method for getting the short location with `Dir.pwd` removed
        #
        # @return [String] the relative pathname and line number
        def short_location
          "#{file}:#{number}"
        end

        # A convenient method for getting the line of source code for the offending line number
        #
        # @return [String] the source code for the file/line number combination
        def source_code(max_line_count: 1)
          return '' unless pathname.exist?

          Minitest::Heat::Source.new(
            pathname.to_s,
            line_number: line_number,
            max_line_count: max_line_count
          )
        end

        # Determines if a given file follows the standard approaching to naming test files.
        #
        # @return [Boolean] true if the file name starts with `test_` or ends with `_test.rb`
        def test_file?
          file.to_s.start_with?('test_') || file.to_s.end_with?('_test.rb')
        end

        private

        UNRECOGNIZED = '(Unrecognized File)'
        UNKNOWN_MODIFICATION_TIME = Time.at(0)
        UNKNOWN_MODIFICATION_SECONDS = -1

        def seconds_ago
          (Time.now - mtime).to_i
        end
      end
    end
  end
end
