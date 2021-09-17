# frozen_string_literal: true

require 'forwardable'

module Minitest
  module Heat
    # Represents a line of code from the project and provides convenient access to information about
    #  the line for displaying in test results
    class Line
      UNKNOWN_MODIFICATION_TIME = -1

      attr_accessor :pathname, :number, :container

      def initialize(pathname:, number:, container: nil)
        @pathname = Pathname(pathname)
        @number = Integer(number)
        @container = String(container)
      end

      def to_a
        [pathname, number]
      end

      def to_s
        "#{location} in `#{container}`"
      end

      def path
        pathname.dirname
      end

      def file
        pathname.basename
      end

      def mtime
        pathname.mtime
      rescue
        UNKNOWN_MODIFICATION_TIME
      end

      def location
        "#{pathname.to_s}:#{number}"
      end

      def short_pathname
        pathname.delete_prefix(Dir.pwd)
      end

      def short_location
        "#{pathname.basename.to_s}:#{number}"
      end

      def age_in_seconds
        (Time.now - mtime).to_i
      end

      def source_code(lines: 1)
      end
    end
  end
end
