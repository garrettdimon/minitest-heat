module Minitest
  module Heat
    # Friendly API for printing nicely-formatted output to the console
    class Output
      class Marker
        SYMBOLS = {
          success:  '·',
          slow:     '–',
          painful:  '—',
          broken:   'B',
          error:    'E',
          skipped:  'S',
          failure:  'F',
        }

        STYLES = {
          success:  :success,
          slow:     :slow,
          painful:  :painful,
          broken:   :error,
          error:    :error,
          skipped:  :skipped,
          failure:  :failure,
        }

        attr_accessor :issue_type, :quantity

        def initialize(issue_type, quantity = 1)
          @issue_type = issue_type
          @quantity = quantity
        end

        def token
          [style, symbols]
        end

        private

        def style
          STYLES.fetch(issue_type) { :default }
        end

        def symbols
          SYMBOLS.fetch(issue_type) { '?' } * quantity
        end
      end
    end
  end
end
