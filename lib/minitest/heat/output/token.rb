# frozen_string_literal: true

module Minitest
  module Heat
    class Output
      # Provides a convenient interface for creating console-friendly output while ensuring
      #   consistency in the applied styles.
      class Token
        class InvalidStyle < ArgumentError; end

        STYLES = {
          success: %i[default green],
          slow: %i[default green],
          painful: %i[bold green],
          error: %i[bold red],
          broken: %i[bold red],
          failure: %i[default red],
          skipped: %i[default yellow],
          warning_light: %i[light yellow],
          italicized: %i[italic gray],
          bold: %i[bold default],
          default: %i[default default],
          muted: %i[light gray]
        }.freeze

        attr_accessor :style_key, :content

        def initialize(style_key, content)
          @style_key = style_key
          @content = content
        end

        def to_s(format = :styled)
          return content unless format == :styled

          [
            style_string,
            content,
            reset_string
          ].join
        end

        def eql?(other)
          style_key == other.style_key && content == other.content
        end
        alias :== eql?

        private

        ESC_SEQUENCE = "\e["
        END_SEQUENCE = 'm'

        WEIGHTS = {
          default: 0,
          bold: 1,
          light: 2,
          italic: 3
        }.freeze

        COLORS = {
          black: 30,
          red: 31,
          green: 32,
          yellow: 33,
          blue: 34,
          magenta: 35,
          cyan: 36,
          gray: 37,
          default: 39
        }.freeze

        def style_string
          "#{ESC_SEQUENCE}#{weight};#{color}#{END_SEQUENCE}"
        end

        def reset_string
          "#{ESC_SEQUENCE}0#{END_SEQUENCE}"
        end

        def weight_key
          style_components[0]
        end

        def color_key
          style_components[1]
        end

        def weight
          WEIGHTS.fetch(weight_key)
        end

        def color
          COLORS.fetch(color_key)
        end

        def style_components
          STYLES.fetch(style_key) { raise InvalidStyle, "'#{style_key}' is not a valid style option for tokens" }
        end
      end
    end
  end
end
