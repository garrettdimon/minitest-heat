# frozen_string_literal: true

module Minitest
  module Heat
    class Output
      class Map
        # extend Forwardable

        attr_accessor :map

        # def_delegators :@results, :errors, :brokens, :failures, :slows, :skips, :problems?, :slows?

        def initialize(map)
          @map = map
          @tokens = []
        end

        def tokens
          map.file_hits.each do |file|
            @tokens << [
              *pathname(file),
              *line_numbers(file)
            ]
          end

          @tokens
        end

        private

        def pathname(file)
          directory = "#{file.pathname.dirname.to_s.delete_prefix(Dir.pwd)}/"
          filename = file.pathname.basename.to_s

          [
            [:default, directory],
            [:bold, filename],
            [:default, ' · ']
          ]
        end

        def hit_line_numbers(file, issue_type)
          line_numbers_for_issue_type = file.issues.fetch(issue_type) { [] }

          return nil if line_numbers_for_issue_type.empty?

          numbers = []
          line_numbers_for_issue_type.sort.map do |line_number|
            numbers << [issue_type, "#{line_number} "]
          end
          numbers
        end

        def line_numbers(file)
          [
            *hit_line_numbers(file, :error),
            *hit_line_numbers(file, :broken),
            *hit_line_numbers(file, :failure),
            *hit_line_numbers(file, :skipped),
            *hit_line_numbers(file, :painful),
            *hit_line_numbers(file, :slow)
          ].compact.sort_by { |number_token| number_token[1] }
        end
      end
    end
  end
end
