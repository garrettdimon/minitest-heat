# frozen_string_literal: true

module Minitest
  module Heat
    class Output
      # Friendly API for printing consistent markers for the various issue types
      class Marker
        SYMBOLS = {
          success: '·',
          slow: '♦',
          painful: '♦',
          broken: 'B',
          error: 'E',
          skipped: 'S',
          failure: 'F',
          reporter: '✖'
        }.freeze

        STYLES = {
          success: :success,
          slow: :slow,
          painful: :painful,
          broken: :error,
          error: :error,
          skipped: :skipped,
          failure: :failure,
          reporter: :error
        }.freeze

        attr_accessor :issue_type

        def initialize(issue_type)
          @issue_type = issue_type
        end

        def token
          [style, symbol]
        end

        private

        def style
          STYLES.fetch(issue_type, :default)
        end

        def symbol
          SYMBOLS.fetch(issue_type, '?')
        end
      end
    end
  end
end
