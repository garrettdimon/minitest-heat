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
          @tokens = []
        end

        def tokens
          # There could be option to expand and display more than one line of source code for the
          # final backtrace line if it might be relevant/helpful?

          # Iterate over the selected lines from the backtrace
          backtrace_lines.each do |backtrace_line|
            # Get the source code for the line from the backtrace
            source_code = source_code_for(backtrace_line)

            parts = [
              indentation_token,
              path_token(backtrace_line),
              file_and_line_number_token(backtrace_line),
              source_code_line_token(source_code)
            ]

            parts << file_freshness(backtrace_line) if most_recently_modified?(backtrace_line)

            @tokens << parts
          end

          @tokens
        end

        def line_count
          DEFAULT_LINE_COUNT
        end

        # This should probably be smart about what lines are displayed in a backtrace.
        # Maybe...
        # ...it could intelligently display the full back trace?
        # ...only the backtrace from the first/last line of project source?
        # ...it behaves a little different when it's a broken test vs. a true exception?
        # ...it could be smart about subtly flagging the lines that show up in the heat map frequently?
        # ...it could be influenced by a "compact" or "robust" reporter super-style?
        # ...it's smart about exceptions that were raised outside of the project?
        # ...it's smart about highlighting lines of code differently based on whether it's source code, test code, or external code?
        def backtrace_lines
          project_lines
        end

        private

        def all_backtrace_lines_from_project?
          backtrace_lines.all? { |line| line.path.to_s.include?(project_root_dir) }
        end

        def project_root_dir
          Dir.pwd
        end

        def project_lines
          backtrace.project_lines.take(line_count)
        end

        def all_lines
          backtrace.parsed_lines.take(line_count)
        end

        def source_code_for(backtrace_entry)
          Minitest::Heat::Source.new(
            "#{backtrace_entry.path}/#{backtrace_entry.file}",
            line_number: backtrace_entry.line_number,
            max_line_count: 1
          )
        end

        def most_recently_modified?(line)
          # If there's more than one line being displayed, and the current line is the freshest
          backtrace_lines.size > 1 && line == backtrace.freshest_project_location
        end

        def indentation_token
          [:default, ' ' * indentation]
        end

        def path_token(line)
          path = "#{line.path}/"

          # If all of the backtrace lines are from the project, no point in the added redundant
          #  noise of showing the project root directory over and over again
          path = path.delete_prefix(project_root_dir) if all_backtrace_lines_from_project?

          [:muted, path]
        end

        def file_and_line_number_token(backtrace_entry)
          [:default, "#{backtrace_entry.file}:#{backtrace_entry.line_number}"]
        end

        def source_code_line_token(source_code)
          [:muted, " `#{source_code.line.strip}`"]
        end

        def file_freshness(line)
          [:bold, " < Most Recently Modified"]
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
      end
    end
  end
end
