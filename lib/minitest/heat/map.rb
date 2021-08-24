# frozen_string_literal: true

module Minitest
  module Heat
    class Map
      attr_reader :hits

      # Score as Weighted number?
      #   E = 5, B = 4, F = 3, S = 1, T = 1
      #   Could/should more recently modified files be bumped?
      #   On failures, the affected class is generatelly more important than source of the failure.
      # EXAMPLE_FORMAT = {
      #   '<class_name>': {
      #     score: 0,
      #     hits: 0,
      #     error: [],
      #     failure: [],
      #     skip: [],
      #     slow: [],
      #   }
      #   '<filename>': {
      #     total: 0,
      #     error: [],
      #     failure: [],
      #     skip: [],
      #     slow: [],
      #     lines: {
      #       '93': ['F', 'E', 'E']
      #     }
      #   }
      # }

      def initialize
        @hits = {}
      end

      def add(filename, line_number, type)
        @hits[filename] ||= { total: 0 }
        @hits[filename][:total] += 1 if type == :error || type == :failure

        @hits[filename][type] ||= []
        @hits[filename][type] << line_number
      end

      def files
        hot_files
          .sort_by { |filename, count| count }
          .reverse
          .take(5)
      end

      private

      def hot_files
        files = {}
        @hits.each_pair do |filename, details|
          # Can't really be a "hot spot" with just a single issue
          next unless details[:total] > 1

          files[filename] = details[:total]
        end
        files
      end
    end
  end
end
