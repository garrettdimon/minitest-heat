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

        attr_accessor :issue_type

        def initialize(issue_type)
          @issue_type = issue_type
        end

        def token
          [style, symbol]
        end

        private

        def style
          STYLES.fetch(issue_type) { :default }
        end

        def symbol
          SYMBOLS.fetch(issue_type) { '?' }
        end
      end
    end
  end
end
