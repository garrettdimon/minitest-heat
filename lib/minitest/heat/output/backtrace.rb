# frozen_string_literal: true

module Minitest
  module Heat
    class Output
      # Builds the collection of tokens for a backtrace when an exception occurs
      class Backtrace
        DEFAULT_LINE_COUNT = 10
        DEFAULT_INDENTATION_SPACES = 2

        attr_accessor :locations, :backtrace

        def initialize(locations)
          @locations = locations
          @backtrace = locations.backtrace
          @tokens = []
        end

        def tokens
          # There could be option to expand and display more than one line of source code for the
          # final backtrace line if it might be relevant/helpful?

          # Iterate over the selected lines from the backtrace
          backtrace_locations.each do |location|
            @tokens << backtrace_location_tokens(location)
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
        def backtrace_locations
          backtrace.locations.take(line_count)
        end

        private

        def backtrace_location_tokens(location)
          [
            indentation_token,
            path_token(location),
            *file_and_line_number_tokens(location),
            source_code_line_token(location.source_code),
            containining_element_token(location),
            most_recently_modified_token(location),
          ].compact
        end

        # Determines if all lines to be displayed are from within the project directory
        #
        # @return [Boolean] true if all lines of the backtrace being displayed are from the project
        def all_backtrace_from_project?
          backtrace_locations.all?(&:project_file?)
        end

        def most_recently_modified?(location)
          # If there's more than one line being displayed, and the current line is the freshest
          backtrace_locations.size > 1 && location == locations.freshest
        end

        def indentation_token
          [:default, ' ' * indentation]
        end

        def path_token(location)
          # If the line is a project file, help it stand out from the backtrace noise
          style = location.project_file? ? :default : :muted

          # If *all* of the backtrace lines are from the project, no point in the added redundant
          # noise of showing the project root directory over and over again
          path_format = all_backtrace_from_project? ? :relative_path : :absolute_path

          [style, location.send(path_format)]
        end

        def file_and_line_number_tokens(location)
          style = location.to_s.include?(Dir.pwd) ? :bold : :muted
          [
            [style, location.filename],
            [:muted, ':'],
            [style, location.line_number]
          ]
        end

        def source_code_line_token(source_code)
          [:muted, " #{Output::SYMBOLS[:arrow]} `#{source_code.line.strip}`"]
        end

        def containining_element_token(location)
          return nil if location.container.nil? || location.container.empty?

          [:muted, " in `#{location.container}`"]
        end

        def most_recently_modified_token(location)
          return nil unless most_recently_modified?(location)

          [:default, " #{Output::SYMBOLS[:middot]} Most Recently Modified File"]
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
