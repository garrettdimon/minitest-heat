# frozen_string_literal: true

module Minitest
  module Heat
    class Output
      class Backtrace
        attr_accessor :location

        def initialize(location)
          @location = location
        end

        def print
        end

        private
      end
    end
  end
end
