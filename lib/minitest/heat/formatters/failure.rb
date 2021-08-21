# frozen_string_literal: true

require 'forwardable'

module Minitest
  module Formatters
    class Failure
      STYLE = [:red].freeze

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
