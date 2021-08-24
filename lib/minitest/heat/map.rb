# frozen_string_literal: true

module Minitest
  module Heat
    class Map
      attr_reader :hits

      # So we can sort hot spots by liklihood of being the most important spot to check out before
      #   trying to fix something. For example, if there's an exception in the file, start there.
      #   if a test is broken, fix it before worrying about tests that have failing assertions.
      #   skipped and slow are shown but don't carry weight because they aren't preventing the test
      #   suite from completing successfuly.
      WEIGHTS = {
        error: 5,
        broken: 3,
        failure: 1,
        skipped: 0,
        slow: 0
      }

      def initialize
        @hits = {}
      end

      def add(filename, line_number, type)
        @hits[filename] ||= { weight: 0, total: 0 }
        @hits[filename][:total] += 1
        @hits[filename][:weight] += WEIGHTS[type]

        @hits[filename][type] ||= []
        @hits[filename][type] << line_number
      end

      def files
        hot_files
          .sort_by { |filename, weight| weight }
          .reverse
          .take(5)
      end

      private

      def hot_files
        files = {}
        @hits.each_pair do |filename, details|
          # Can't really be a "hot spot" with just a single issue
          next unless details[:total] > 1

          files[filename] = details[:weight]
        end
        files
      end
    end
  end
end
