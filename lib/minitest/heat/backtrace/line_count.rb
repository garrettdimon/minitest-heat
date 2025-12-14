# frozen_string_literal: true

module Minitest
  module Heat
    class Backtrace
      # Determines an optimal line count for backtrace locations in order to have relevant
      #   information but keep the backtrace as compact as possible
      class LineCount
        DEFAULT_LINE_COUNT = 20

        attr_accessor :locations

        def initialize(locations)
          @locations = locations
        end

        def earliest_project_location
          locations.rindex { |element| element.project_file? }
        end

        def max_location
          [locations.size - 1, 0].max
        end

        def limit
          [
            DEFAULT_LINE_COUNT,
            earliest_project_location,
            max_location
          ].compact.min
        end
      end
    end
  end
end
