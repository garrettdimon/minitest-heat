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
            # If there's legitimate failures or errors, skips and slows aren't relevant
            next unless relevant_issue_types?(hit)

            @tokens << [[:muted, ""]]
            @tokens << file_summary_tokens(hit)

            repeats = repeated_line_numbers(hit)
            next unless repeats.any?

            repeats.each do |line_number|
              @tokens << [[:muted, "  Issues on Line #{line_number} initially triggered from these locations:"]]

              traces = hit.lines[line_number.to_s]
              sorted_traces = traces.sort_by { |trace| trace.locations.last.line_number }

              sorted_traces.each do |trace|
                @tokens << origination_location_token(trace)
              end
            end
          end

          @tokens
        end

        private

        def file_summary_tokens(hit)
          pathname_tokens = pathname(hit)
          line_number_list_tokens = sorted_line_number_list(hit)

          [*pathname_tokens, *line_number_list_tokens]
        end

        def origination_location_token(trace)
          # The earliest project line from the backtrace—this is probabyl wholly incorrect in terms
          # of what would be the most helpful line to display, but it's a start.
          location = trace.locations.last

          [
            [:muted, "  #{Output::SYMBOLS[:arrow]} "],
            [:default, location.relative_filename],
            [:muted, ':'],
            [:default, location.line_number],
            [:muted, " in #{location.container}"],
            [:muted, " #{Output::SYMBOLS[:arrow]} `location.source_code.line.strip`"],
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
          intersection_issue_types = relevant_issue_types & hit.issues.keys

          intersection_issue_types.any?
        end

        def repeated_line_numbers(hit)
          repeated_line_numbers = []

          hit.lines.each_pair do |line_number, traces|
            # If there aren't multiple traces for a line number, it's not a repeat, right?
            next unless traces.size > 1

            repeated_line_numbers << Integer(line_number)
          end

          repeated_line_numbers.sort
        end

        def repeated_line_numbers?(hit)
          repeated_line_numbers(hit).any?
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

        def line_number_tokens_for_hit(hit)
          line_number_tokens = []

          relevant_issue_types.each do |issue_type|
            # Retrieve any line numbers for the issue type
            line_numbers_for_issue_type = hit.issues.fetch(issue_type) { [] }

            # Build the list of tokens representing styled line numbers
            line_numbers_for_issue_type.each do |line_number|
              line_number_tokens << line_number_token(issue_type, line_number)
            end
          end

          line_number_tokens.compact
        end

        def line_number_token(style, line_number)
          [style, "#{line_number} "]
        end

        # Generates the line number tokens styled based on their error type
        #
        # @param [Hit] hit the instance of the hit file details to build the heat map entry
        #
        # @return [Array] the arrays representing the line number tokens to display next to a file
        #   name in the heat map
        def sorted_line_number_list(hit)
          # Sort the collected group of line number hits so they're in order
          line_number_tokens_for_hit(hit).sort do |a, b|
            # Ensure the line numbers are integers for sorting (otherwise '100' comes before '12')
            first_line_number = Integer(a[1].strip)
            second_line_number = Integer(b[1].strip)

            first_line_number <=> second_line_number
          end
        end
      end
    end
  end
end
