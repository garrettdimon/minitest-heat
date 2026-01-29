# frozen_string_literal: true

require 'forwardable'

module Minitest
  module Heat
    # For managing configuration options on how Minitest Heat should handle results
    class Configuration
      DEFAULTS = {
        slow_threshold: 1.0,
        painfully_slow_threshold: 3.0,
        inherently_slow_paths: []
      }.freeze

      attr_accessor :slow_threshold,
                    :painfully_slow_threshold,
                    :inherently_slow_paths

      def initialize
        @slow_threshold = DEFAULTS[:slow_threshold]
        @painfully_slow_threshold = DEFAULTS[:painfully_slow_threshold]
        @inherently_slow_paths = DEFAULTS[:inherently_slow_paths].dup
      end

      def inherently_slow_path?(path)
        inherently_slow_paths.any? { |prefix| path.start_with?(prefix) }
      end
    end
  end
end
