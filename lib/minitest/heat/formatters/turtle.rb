# frozen_string_literal: true

require 'forwardable'

module Minitest
  module Formatters
    class Turtle
      STYLE = [:yellow].freeze

      def summary
        []
      end

      def details
        []
      end

      def code
        []
      end
    end
  end
end
