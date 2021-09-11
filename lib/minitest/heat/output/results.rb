# frozen_string_literal: true

module Minitest
  module Heat
    class Output
      class Results
        attr_accessor :results

        def initialize(results)
          @results = results
        end

        def print
        end

        private
      end
    end
  end
end
