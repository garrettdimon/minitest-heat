# frozen_string_literal: true

module Minitest
  module Heat
    class Output
      # Builds the collection of tokens for a backtrace when an exception occurs
      class Backtrace
        DEFAULT_LINE_COUNT = 5
        DEFAULT_INDENTATION_SPACES = 2

        attr_accessor :location, :backtrace

        def initialize(location)
          @location = location
          @backtrace = location.backtrace
        end

        def tokens
        end

        private


        def lines
          # This should probably be smart about what lines are displayed in a backtrace.
          # - Does it display a full back trace?
          # - Maybe only the backtrace from the first/last line of projet source?
          # - Maybe it behaves a little different when it's a broken test vs. a true exception?
          # - Maybe it could be smart about subtly flagging the lines that show up in the heat map frequently?
          # - Maybe it could be influenced by a "compact" or "robust" reporter super-style?
          # - Maybe it's smart about exceptions that were raised outside of the project?
          # - Maybe it's smart about highlighting lines of code differently based on whether it's source code, test code, or external code?
        end

        # def something
        #   backtrace_lines = issue.backtrace.project_lines

        #   backtrace_line = backtrace_lines.first
        #   filename = "#{backtrace_line.path.delete_prefix(Dir.pwd)}/#{backtrace_line.file}"

        #   backtrace_lines.take(3).each do |line|
        #     source = Minitest::Heat::Source.new("#{backtrace_line.path}/#{backtrace_line.file}", line_number: line.number, max_line_count: 1)

        #     text(:muted, "  #{line.path.delete_prefix("#{Dir.pwd}/")}/")
        #     text(:muted, "#{line.file}:#{line.number}")
        #     text(:source, " `#{source.line.strip}`")

        #     newline
        #   end
        # end
      end
    end
  end
end
