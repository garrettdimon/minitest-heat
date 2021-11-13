# frozen_string_literal: true

module Minitest
  module Heat
    # Structured approach to collecting the locations of issues for generating a heat map
    class Map
      MAXIMUM_FILES_TO_SHOW = 5

      # HITS_SAMPLE = {
      #   '<file_name>': {
      #     error: [12, 12, 12, 23, 32, 34],
      #     failure: [10, 92]
      #   }
      # }

      # LOCATIONS_SAMPLE = {
      #   '<file_name>': {
      #     '<#>': [<Hit>, <Hit>, <Hit>],
      #     '<#>': [<Hit>]
      #   }
      # }

      attr_reader :hits

      def initialize
        @hits = {}
      end

      # Records a hit to the list of files and issue types
      # @param filename [String] the unique path and file name for recordings hits
      # @param line_number [Integer] the line number where the issue was encountered
      # @param type [Symbol] the type of issue that was encountered (i.e. :failure, :error, etc.)
      #
      # @return [void]
      def add(filename, line_number, type, preceding_location: nil)
        @hits[filename] ||= Hit.new(filename)

        @hits[filename].log(type.to_sym, line_number, preceding_location: preceding_location)
      end

      # Returns a subset of affected files to keep the list from being overwhelming
      #
      # @return [Array] the list of files and the line numbers for each encountered issue type
      def file_hits
        hot_files.take(MAXIMUM_FILES_TO_SHOW)
      end

      private

      # Sorts the files by hit "weight" so that the most problematic files are at the beginning
      #
      # @return [Array] the collection of files that encountred issues
      def hot_files
        hits.values.sort_by(&:weight).reverse
      end
    end
  end
end
