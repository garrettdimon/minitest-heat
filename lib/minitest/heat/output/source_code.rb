# frozen_string_literal: true

module Minitest
  module Heat
    class Output
      # Generates the tokens representing a specific set of source code lines
      class SourceCode
        DEFAULT_LINE_COUNT = 3
        DEFAULT_INDENTATION_SPACES = 2
        HIGHLIGHT_KEY_LINE = true

        attr_reader :filename, :line_number, :max_line_count

        # Provides a collection of tokens representing the output of source code
        # @param filename [String] the absolute path to the file containing the source code
        # @param line_number [Integer, String] the primary line number of interest for the file
        # @param max_line_count: DEFAULT_LINE_COUNT [Integer] maximum total number of lines to
        #   retrieve around the target line (including the target line)
        #
        # @return [self]
        def initialize(filename, line_number, max_line_count: DEFAULT_LINE_COUNT)
          @filename = filename
          @line_number = line_number.to_s
          @max_line_count = max_line_count
          @tokens = []
        end

        # The collection of style content tokens to print
        #
        # @return [Array<Array<Token>>] an array of arrays of tokens where each top-level array
        #   represents a line where the first element is the line_number and the second is the line
        #   of code to display
        def tokens
          source.lines.each_index do |i|
            current_line_number  = source.line_numbers[i]
            current_line_of_code = source.lines[i]

            number_style, line_style = styles_for(current_line_of_code)

            @tokens << [
              line_number_token(number_style, current_line_number),
              line_of_code_token(line_style, current_line_of_code)
            ]
          end
          @tokens
        end

        # The number of digits for the largest line number returned. This is used for formatting and
        #   text justification so that line numbers are right-aligned
        #
        # @return [Integer] the number of digits in the longest line number returned
        def max_line_number_digits
          source
            .line_numbers
            .map(&:to_s)
            .map(&:length)
            .max
        end

        # Whether to visually highlight the target line when displaying the source code. Currently
        #   defauls to true, but long-term, this is a likely candidate to be configurable. For
        #   example, in the future, highlighting could only be used if the source includes more than
        #   three lines. Or it could be something end users could disable in order to reduce noise.
        #
        # @return [Boolean] true if the target line should be highlighted
        def highlight_key_line?
          HIGHLIGHT_KEY_LINE
        end

        # The number of spaces each line of code should be indented. Currently defaults to 2 in
        #   order to provide visual separation between test failures, but in the future, it could
        #   be configurable in order to save horizontal space and create more compact output. For
        #   example, it could be smart based on line length and total available horizontal terminal
        #   space, or there could be higher-level "display" setting that could have a `:compact`
        #   option that would reduce the space used.
        #
        # @return [type] [description]
        def indentation
          DEFAULT_INDENTATION_SPACES
        end

        private

        # The source instance for retrieving the relevant lines of source code
        #
        # @return [Source] a Minitest::Heat::Source instance
        def source
          @source ||= Minitest::Heat::Source.new(
            filename,
            line_number: line_number,
            max_line_count: max_line_count
          )
        end

        # Determines how to style a given line of code token. For now, it's only used for
        #   highlighting the targeted line of code, but it could also be adjusted to mute the line
        #   number or otherwise change the styling of how lines of code are displayed
        # @param line_of_code [String] the content representing the line of code we're currently
        #   generating a token for
        #
        # @return [Array<Symbol>] the Token styles for the line number and line of code
        def styles_for(line_of_code)
          if line_of_code == source.line && highlight_key_line?
            %i[default default]
          else
            %i[muted muted]
          end
        end

        # The token representing a given line number. Adds the appropriate indention and
        #   justification to right align the line numbers
        # @param style [Symbol] the symbol representing the style for the line number token
        # @param line_number [Integer,String] the digits representing the line number
        #
        # @return [Array] the style/content token for the current line number
        def line_number_token(style, line_number)
          [style, "#{' ' * indentation}#{line_number.to_s.rjust(max_line_number_digits)} "]
        end

        # The token representing the content of a given line of code.
        # @param style [Symbol] the symbol representing the style for the line of code token
        # @param line_number [Integer,String] the content of the line of code
        #
        # @return [Array] the style/content token for the current line of code
        def line_of_code_token(style, line_of_code)
          [style, line_of_code]
        end
      end
    end
  end
end
