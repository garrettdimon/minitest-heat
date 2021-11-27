# frozen_string_literal: true

module Minitest
  module Heat
    class Output
      # Builds the collection of tokens for displaying a backtrace when an exception occurs
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
          # Iterate over the selected lines from the backtrace
          @tokens = backtrace_locations.map { |location| backtrace_location_tokens(location) }
        end

        # Determines the number of lines to display from the backtrace.
        #
        # @return [Integer] the number of lines to limit the backtrace to
        def line_count
          # Defined as a method instead of using the constant directlyr in order to easily support
          # adding options for controlling how many lines are displayed from a backtrace.
          #
          # For example, instead of a fixed number, the backtrace could dynamically calculate how
          # many lines it should displaye in order to get to the origination point. Or it could have
          # a default, but inteligently go back further if the backtrace meets some criteria for
          # displaying more lines.
          DEFAULT_LINE_COUNT
        end

        # A subset of parsed lines from the backtrace.
        #
        # @return [Array<Location>] the backtrace locations determined to be most relevant to the
        #   context of the underlying issue
        def backtrace_locations
          # This could eventually have additional intelligence to determine what lines are most
          # relevant for a given type of issue. For now, it simply takes the line numbers, but the
          # idea is that long-term, it could adjust that on the fly to keep the line count as low
          # as possible but expand it if necessary to ensure enough context is displayed.
          #
          # - If there's no clear cut details about the source of the error from within the project,
          #   it could display the entire backtrace without filtering anything.
          # - It could scan the backtrace to the first appearance of project files and then display
          #   all of the lines that occurred after that instance
          # - It coudl filter the lines differently whether the issue originated from a test or from
          #   the source code.
          # - It could allow supporting a "compact" or "robust" reporter style so that someone on
          #   a smaller screen could easily reduce the information shown so that the results could
          #   be higher density even if it means truncating some occasionally useful details
          # - It could be smarter about displaying context/guidance when the full backtrace is from
          #   outside the project's code
          #
          # But for now. It just grabs some lines.
          backtrace.locations.take(line_count)
        end

        private

        def backtrace_location_tokens(location)
          [
            indentation_token,
            path_token(location),
            *file_and_line_number_tokens(location),
            containining_element_token(location),
            source_code_line_token(location),
            most_recently_modified_token(location),
          ].compact
        end

        # Determines if all lines to be displayed are from within the project directory
        #
        # @return [Boolean] true if all lines of the backtrace being displayed are from the project
        def all_backtrace_from_project?
          backtrace_locations.all?(&:project_file?)
        end

        # Determines if the file referenced by a backtrace line is the most recently modified file
        #   of all the files referenced in the visible backtrace locations.
        #
        # @param [Location] location the location to examine
        #
        # @return [<type>] <description>
        #
        def most_recently_modified?(location)
          # If there's more than one line being displayed (otherwise, with one line, of course it's
          # the most recently modified because there_aren't any others) and the current line is the
          # same as the freshest location in the backtrace
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

        def source_code_line_token(location)
          return nil unless location.project_file?

          [:muted, " #{Output::SYMBOLS[:arrow]} `#{location.source_code.line.strip}`"]
        end

        def containining_element_token(location)
          return nil if !location.project_file? || location.container.nil? || location.container.empty?

          [:muted, " in #{location.container}"]
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
