# frozen_string_literal: true

module Minitest
  module Heat
    class Output
      class Map
        attr_accessor :results

        def initialize(results)
          @results = results
          @tokens = []
        end

        def tokens
          map.file_hits.each do |hit|
            file_tokens = pathname(hit)
            line_number_tokens = line_numbers(hit)

            next if line_number_tokens.empty?

            @tokens << [
              *file_tokens,
              *line_number_tokens
            ]
          end

          @tokens
        end

        private

        def map
          results.heat_map
        end

        def relevant_issue_types
          issue_types = %i[error broken failure]

          issue_types << :skipped unless results.problems?
          issue_types << :painful unless results.problems? || results.skips.any?
          issue_types << :slow    unless results.problems? || results.skips.any?

          issue_types
        end

        def pathname(file)
          directory = "#{file.pathname.dirname.to_s.delete_prefix(Dir.pwd)}/".delete_prefix('/')
          filename = file.pathname.basename.to_s

          [
            [:default, directory],
            [:bold, filename],
            [:default, ' · ']
          ]
        end

        def hit_line_numbers(file, issue_type)
          numbers = []
          line_numbers_for_issue_type = file.issues.fetch(issue_type) { [] }
          line_numbers_for_issue_type.map do |line_number|
            numbers << [issue_type, "#{line_number} "]
          end

          numbers
        end

        def line_numbers(file)
          line_number_tokens = []

          # Merge the hits for all issue types into one list
          relevant_issue_types.each do |issue_type|
            line_number_tokens += hit_line_numbers(file, issue_type)
          end

          # Sort the collected group of line number hits so they're in order
          line_number_tokens.compact.sort do |a, b|
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
