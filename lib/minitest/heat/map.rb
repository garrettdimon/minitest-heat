# frozen_string_literal: true

module Minitest
  module Heat
    class Map
      MAXIMUM_FILES_TO_SHOW = 5

      attr_reader :hits

      def initialize
        @hits = {}
      end

      def add(filename, line_number, type)
        @hits[filename] ||= Hit.new(filename)

        @hits[filename].log(type, line_number)
      end

      def file_hits
        hot_files.take(MAXIMUM_FILES_TO_SHOW)
      end

      private

      def hot_files
        hits.values.sort_by(&:weight).reverse
      end
    end
  end
end
