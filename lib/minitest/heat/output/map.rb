# frozen_string_literal: true

module Minitest
  module Heat
    class Output
      class Map
        # extend Forwardable

        attr_accessor :map

        # def_delegators :@results, :errors, :brokens, :failures, :slows, :skips, :problems?, :slows?

        def initialize(map)
          @map = map
          @tokens = []
        end

        def tokens
          map.files.each do |file|
            @tokens << [
              [*hits(file)],
              [*pathname(file)],
              [*line_numbers(file)]
            ]
          end


          @tokens
        end

        private

        def max_hits_count
          @max_hits_count = map.files
        end

        def hits(file)
          []
        end

        def pathname(file)
          []
        end

        def line_numbers(file)
          []
        end

        def original
          map.files.each do |file|
            pathname = Pathname(file[0])

            path = pathname.dirname.to_s
            filename = pathname.basename.to_s

            values = map.hits[pathname.to_s]


            text(:error, 'E' * values[:error].size)     if values[:error]&.any?
            text(:broken, 'B' * values[:broken].size)   if values[:broken]&.any?
            text(:failure, 'F' * values[:failure].size) if values[:failure]&.any?

            unless values[:error]&.any? || values[:broken]&.any? || values[:failure]&.any?
              text(:skipped, 'S' * values[:skipped].size) if values[:skipped]&.any?
              text(:painful, '—' * values[:painful].size) if values[:painful]&.any?
              text(:slow, '–' * values[:slow].size)       if values[:slow]&.any?
            end

            text(:muted, ' ') if map.hits.any?

            text(:muted, "#{path.delete_prefix(Dir.pwd)}/")
            text(:default, filename)

            text(:muted, ':')

            all_line_numbers = values.fetch(:error, []) + values.fetch(:failure, [])
            all_line_numbers += values.fetch(:skipped, [])

            line_numbers = all_line_numbers.compact.uniq.sort
            line_numbers.each { |line_number| text(:muted, "#{line_number} ") }
            newline
          end
          newline
        end

      end
    end
  end
end
