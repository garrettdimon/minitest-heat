# frozen_string_literal: true

require 'forwardable'

module Minitest
  module Heat
    # Represents a line of code from the project and provides convenient access to information about
    #  the line for displaying in test results
    class Line
      attr_accessor :pathname, :number, :container
      alias line_number number

      def initialize(pathname:, number:, container: nil)
        @pathname = Pathname(pathname)
        @number = number.to_i
        @container = container.to_s
      end

      # Convenient interface to read a line from a backtrace convert it to usable components
      def self.parse_backtrace(raw_text)
        raw_pathname, raw_line_number, raw_container = raw_text.split(':')
        raw_container = raw_container.delete_prefix('in `').delete_suffix("'")

        new(pathname: raw_pathname, number: raw_line_number, container: raw_container)
      end

      def to_s
        "#{location} in `#{container}`"
      end

      def path
        pathname.exist? ? pathname.dirname : UNRECOGNIZED
      end

      def file
        pathname.exist? ? pathname.basename : UNRECOGNIZED
      end

      def mtime
        pathname.exist? ? pathname.mtime : UNKNOWN_MODIFICATION_TIME
      end

      def age_in_seconds
        pathname.exist? ? seconds_ago : UNKNOWN_MODIFICATION_SECONDS
      end

      def location
        "#{pathname}:#{number}"
      end

      def short_location
        "#{file}:#{number}"
      end

      def source_code(max_line_count: 1)
        Minitest::Heat::Source.new(
          pathname.to_s,
          line_number: line_number,
          max_line_count: max_line_count
        )
      end

      private

      UNRECOGNIZED = '(Unrecognized File)'
      UNKNOWN_MODIFICATION_TIME = Time.at(0)
      UNKNOWN_MODIFICATION_SECONDS = -1

      def seconds_ago
        (Time.now - mtime).to_i
      end
    end
  end
end
