# frozen_string_literal: true

require 'forwardable'

module Minitest
  module Heat
    # For managing configuration options on how Minitest Heat should handle results
    class Configuration
      DEFAULTS = {
        slow_threshold:           1.0,
        painfully_slow_threshold: 3.0
      }.freeze

      attr_accessor :slow_threshold,
                    :painfully_slow_threshold

      def initialize
        @slow_threshold           = DEFAULTS[:slow_threshold]
        @painfully_slow_threshold = DEFAULTS[:painfully_slow_threshold]
      end
    end
  end
end
