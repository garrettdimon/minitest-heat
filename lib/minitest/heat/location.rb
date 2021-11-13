# frozen_string_literal: true

module Minitest
  module Heat
    # Consistent structure for extracting information about a given location. In addition to the
    #   pathname to the file and the line number in the file, it can also include information about
    #   the containing method or block and retrieve source code for the location.
    class Location
      attr_accessor :raw_pathname, :raw_line_number, :raw_container

      def initialize(pathname:, line_number:, container: nil)
        @raw_pathname = pathname
        @raw_line_number = line_number
        @raw_container = container
      end

      def exists?
        pathname.exist? && source_code.lines.any?
      end

      def pathname
        Pathname(raw_pathname)
      rescue ArgumentError
        Pathname(Dir.pwd)
      end

      def path
        pathname.dirname.to_s
      end

      def filename
        pathname.basename.to_s
      end

      def absolute_pathname
        pathname.to_s
      end

      def relative_pathname
        absolute_pathname.delete_prefix(Dir.pwd)
      end

      def line_number
        Integer(raw_line_number)
      rescue ArgumentError
        1
      end

      def container
        raw_container.nil? ? '(Unknown Container)' : String(raw_container)
      end

      def source_code(max_line_count: 1)
        Minitest::Heat::Source.new(
          pathname&.to_s,
          line_number: line_number,
          max_line_count: max_line_count
        )
      end
    end
  end
end
