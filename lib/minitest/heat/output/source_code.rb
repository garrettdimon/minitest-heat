# frozen_string_literal: true

module Minitest
  module Heat
    class Output
      class SourceCode
        DEFAULT_LINE_COUNT = 3
        DEFAULT_INDENTATION_SPACES = 2
        HIGHLIGHT_KEY_LINE = true

        attr_reader :filename, :line_number

        def initialize(filename, line_number)
          @filename = filename
          @line_number = line_number
          @tokens = []
        end

        def print
          show_source
        end

        private

        def source
          @source ||= Minitest::Heat::Source.new(
            filename,
            line_number: line_number,
            max_line_count: DEFAULT_LINE_COUNT
          )
        end

        def show_source
          source.lines.each_index do |i|
            current_line_number  = source.line_numbers[i]
            current_line_of_code = source.lines[i]

            number_style, line_style = styles_for(current_line_of_code)

            @tokens << [
              line_number_token(number_style, current_line_number),
              line_of_code_token(line_style, current_line_of_code)
            ]
          end
        end

        def max_line_number_length
          source
            .line_numbers
            .map(&:to_s)
            .map(&:length)
            .max
        end

        def highlight_key_line?
          HIGHLIGHT_KEY_LINE
        end

        def indentation
          DEFAULT_INDENTATION_SPACES
        end

        def styles_for(line_of_code)
          if line_of_code == source.line && highlight_key_line?
            [:default, :default]
          else
            [:muted, :muted]
          end
        end

        def line_number_token(style, line_number)
          Output::Token.new(style, "#{' ' * indentation}#{line_number.to_s.rjust(max_line_number_length)} ")
        end

        def line_of_code_token(style, line_of_code)
          Output::Token.new(style, line_of_code)
        end
      end
    end
  end
end
