# frozen_string_literal: true

require 'forwardable'

module Minitest
  module Formatters
    class Error
      STYLE = [:red, :bold].freeze

      def summary
        [
          [STYLE, :label], [:subtle, :spacer], [STYLE, :summary], [:subtle, :arrow], [STYLE,  :class],
        ]
      end

      def details
        [
          [:default, :test_name], [:subtle, :spacer], [:sublte, :test_class],
        ]
      end

      def code
        [
          []
        ]
      end
    end
  end
end
