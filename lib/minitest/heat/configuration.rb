# frozen_string_literal: true

require 'forwardable'

module Minitest
  module Heat
    # For managing configuration options on how Minitest Heat should handle results
    class Configuration
      attr_accessor :slow_threshold,
                    :painfully_slow_threshold

      def initialize
        @slow_threshold = 1.0
        @painfully_slow_threshold = 3.0
      end
    end
  end
end
