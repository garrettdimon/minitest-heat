# frozen_string_literal: true

module Minitest
  module Heat
    class Output
      class Location
        attr_accessor :location

        def initialize(location)
          @location = location
        end

        def tokens
        end

        private
      end
    end
  end
end
