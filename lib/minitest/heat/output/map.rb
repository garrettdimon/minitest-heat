# frozen_string_literal: true

module Minitest
  module Heat
    class Output
      # Generates the tokens to output the resulting heat map
      class Map
        attr_accessor :results

        def initialize(results)
          @results = results
          @tokens = []
        end

        def tokens
          results.heat_map.file_hits.each do |hit|
            # Focus on the relevant issues based on most significant problems. i.e. If there are
            # legitimate failures or errors, skips and slows aren't relevant
            next unless relevant_issue_types?(hit)

            # Add a new line
            @tokens << [[:muted, '']]

            # Build the summary line for the file
            @tokens << file_summary_tokens(hit)

            # Get the set of line numbers that appear more than once
            repeated_line_numbers = find_repeated_line_numbers_in(hit)

            # Only display more details if the same line number shows up more than once
            next unless repeated_line_numbers.any?

            repeated_line_numbers.each do |line_number|
              # Get the backtraces for the given line numbers
              traces = hit.lines[line_number.to_s]

              # If there aren't any traces there's no way to provide additional details
              break unless traces.any?

              # A short summary explaining the details that will follow
              @tokens << [[:default, "  Line #{line_number}"], [:muted, ' issues triggered from:']]

              # The last relevant location for each error's backtrace
              @tokens += origination_sources(traces)
            end
          end

          @tokens
        end

        private

        def origination_sources(traces)
          # 1. Only pull the traces that have proper locations
          # 2. Sort the traces by the most recent line number so they're displayed in numeric order
          # 3. Get the final relevant location from the trace
          traces
            .select  { |trace| trace.locations.any? }
            .sort_by { |trace| trace.locations.last.line_number }
            .map     { |trace| origination_location_token(trace) }
        end

        def file_summary_tokens(hit)
          pathname_tokens = pathname(hit)
          line_number_list_tokens = line_number_tokens_for_hit(hit)

          [*pathname_tokens, *line_number_list_tokens]
        end

        def origination_location_token(trace)
          # The earliest project line from the backtrace—this is probabyl wholly incorrect in terms
          # of what would be the most helpful line to display, but it's a start. Otherwise, the
          # logic will need to compare all traces for the issue and find the unique origination
          # lines
          location = trace.locations.last

          [
            [:muted, "  #{Output::SYMBOLS[:arrow]} "],
            [:default, location.relative_filename],
            [:muted, ':'],
            [:default, location.line_number],
            [:muted, " in #{location.container}"],
            [:muted, " #{Output::SYMBOLS[:arrow]} `#{location.source_code.line.strip}`"]
          ]
        end

        def relevant_issue_types
          # These are always relevant.
          issue_types = %i[error broken failure]

          # These are only relevant if there aren't more serious isues.
          issue_types << :skipped unless results.problems?
          issue_types << :painful unless results.problems? || results.skips.any?
          issue_types << :slow    unless results.problems? || results.skips.any?

          issue_types
        end

        def relevant_issue_types?(hit)
          # The intersection of which issue types are relevant based on the context and which issues
          # matc those issue types
          intersection_issue_types = relevant_issue_types & hit.issues.keys

          intersection_issue_types.any?
        end

        def find_repeated_line_numbers_in(hit)
          repeated_line_numbers = []

          hit.lines.each_pair do |line_number, traces|
            # If there aren't multiple traces for a line number, it's not a repeat
            next unless traces.size > 1

            repeated_line_numbers << Integer(line_number)
          end

          repeated_line_numbers.sort
        end

        def pathname(hit)
          directory = hit.pathname.dirname.to_s.delete_prefix("#{Dir.pwd}/")
          filename = hit.pathname.basename.to_s

          [
            [:default, "#{directory}/"],
            [:bold, filename],
            [:default, ' · ']
          ]
        end

        # Gets the list of line numbers for a given hit location (i.e. file) so they can be
        #   displayed after the file name to show which lines were problematic
        # @param hit [Hit] the instance to extract line numbers from
        #
        # @return [Array<Symbol,String>] [description]
        def line_number_tokens_for_hit(hit)
          line_number_tokens = []

          relevant_issue_types.each do |issue_type|
            # Retrieve any line numbers for the issue type
            line_numbers_for_issue_type = hit.issues.fetch(issue_type) { [] }

            # Build the list of tokens representing styled line numbers
            line_numbers_for_issue_type.uniq.sort.each do |line_number|
              frequency = line_numbers_for_issue_type.count(line_number)

              line_number_tokens += line_number_token(issue_type, line_number, frequency)
            end
          end

          line_number_tokens.compact
        end

        # Builds a token representing a styled line number
        #
        # @param style [Symbol] the relevant display style for the issue
        # @param line_number [Integer] the affected line number
        #
        # @return [Array<Symbol,Integer>] array token representing the line number and issue type
        def line_number_token(style, line_number, frequency)
          if frequency > 1
            [
              [style, line_number.to_s],
              [:muted, "✕#{frequency} "]
            ]
          else
            [[style, "#{line_number} "]]
          end
        end

        # # Sorts line number tokens so that line numbers are displayed in order regardless of their
        # #   underlying issue type
        # #
        # # @param hit [Hit] the instance of the hit file details to build the heat map entry
        # #
        # # @return [Array] the arrays representing the line number tokens to display next to a file
        # #   name in the heat map. ex [[:error, 12], [:falure, 13]]
        # def sorted_line_number_list(hit)
        #   # Sort the collected group of line number hits so they're in order
        #   line_number_tokens_for_hit(hit).sort do |a, b|
        #     # Ensure the line numbers are integers for sorting (otherwise '100' comes before '12')
        #     first_line_number = Integer(a[1].strip)
        #     second_line_number = Integer(b[1].strip)

        #     first_line_number <=> second_line_number
        #   end
        # end
      end
    end
  end
end
