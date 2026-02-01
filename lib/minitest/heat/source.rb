# frozen_string_literal: true

module Minitest
  module Heat
    # Gets the most relevant lines of code surrounding the specified line of code
    class Source
      attr_reader :filename

      attr_accessor :line_number, :max_line_count, :context

      CONTEXTS = %i[before around after].freeze

      def initialize(filename, line_number:, max_line_count: 1, context: :around)
        @filename = filename
        @line_number = Integer(line_number)
        @max_line_count = max_line_count
        @context = context
        @raw_lines = nil
      end

      # Returns relevant lines as a hash with line numbers as the keys
      #
      # @return [Hash] hash of relevant lines with line numbers as keys
      def to_h = line_numbers.map(&:to_s).zip(lines).to_h

      # Looks up the line of code referenced
      #
      # @return [String] the line of code at filename:line_number
      def line = file_lines[line_number - 1]

      # Looks up the available lines of code around the referenced line number
      #
      # @return [Array<String>] the range of lines of code around
      def lines
        return [line].compact if max_line_count == 1

        file_lines[(line_numbers.first - 1)..(line_numbers.last - 1)]
      end

      # Line numbers for the returned lines
      #
      # @return [Array<Integer>] the line numbers corresponding to the lines returned
      def line_numbers = (first_line_number..last_line_number).to_a.uniq

      # Reads (and chomps) the lines of the target file
      #
      # @return [type] [description]
      def file_lines
        @raw_lines ||= File.readlines(filename, chomp: true)
        # Remove trailing empty lines, checking for nil/empty safely
        @raw_lines.pop while @raw_lines.any? && @raw_lines.last&.strip.to_s.empty?

        @raw_lines
      rescue Errno::ENOENT, Errno::EACCES, Errno::EISDIR, IOError, Encoding::UndefinedConversionError
        # Occasionally, for a variety of reasons, a file can't be read. In those cases, it's best to
        # return no source code lines rather than have the test suite raise an error unrelated to
        # the code being tested because that gets confusing.
        []
      end

      private

      # The largest possible value for line numbers
      #
      # @return [Integer] the last line number of the file
      def max_line_number = file_lines.length

      # The number of the first line of code to return
      #
      # @return [Integer] line number
      def first_line_number
        target = line_number - first_line_offset - leftover_trailing_lines_count

        # Can't go earlier than the first line
        [target, 1].max
      end

      # The number of the last line of code to return
      #
      # @return [Integer] line number
      def last_line_number
        target = line_number + last_line_offset + leftover_preceding_lines_count

        # Can't go past the end of the file
        [target, max_line_number].min
      end

      # The target number of preceding lines to include
      #
      # @return [Integer] number of preceding lines to include
      def first_line_offset
        case context
        when :before then other_lines_count
        when :around then preceding_lines_split_count
        when :after then 0
        end
      end

      # The target number of trailing lines to include
      #
      # @return [Integer] number of trailing lines to include
      def last_line_offset
        case context
        when :before then 0
        when :around then trailing_lines_split_count
        when :after then other_lines_count
        end
      end

      # If the preceding lines offset takes_it past the beginning of the file, this provides the
      # total number of lines that weren't used
      #
      # @return [Integer] number of preceding lines that don't exist
      def leftover_preceding_lines_count
        target_line_number = line_number - first_line_offset

        target_line_number < 1 ? target_line_number.abs + 1 : 0
      end

      # If the trailing lines offset takes_it past the end of the file, this provides the total
      # number of lines that weren't used
      #
      # @return [Integer] number of trailing lines that don't exist
      def leftover_trailing_lines_count
        target_line_number = line_number + last_line_offset

        target_line_number > max_line_number ? target_line_number - max_line_number : 0
      end

      # The total number of lines to include in addition to the primary line
      def other_lines_count = max_line_count - 1

      # Round up preceding lines if it's uneven because preceding lines are more likely to be
      # helpful when debugging
      def preceding_lines_split_count = (other_lines_count / 2).round(0, half: :up)

      # Round down preceding lines because they provide context in the file but don't contribute
      # in terms of the code that led to the error
      def trailing_lines_split_count = (other_lines_count / 2).round(0, half: :down)
    end
  end
end
