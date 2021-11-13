# frozen_string_literal: true

module Minitest
  module Heat
    # Consistent structure for extracting information about a given location. In addition to the
    #   pathname to the file and the line number in the file, it can also include information about
    #   the containing method or block and retrieve source code for the location.
    class Location
      UNRECOGNIZED = '(Unrecognized File)'
      UNKNOWN_MODIFICATION_TIME = Time.at(0)
      UNKNOWN_MODIFICATION_SECONDS = -1

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

      # A safe interface to getting a string representing the path portion of the file
      #
      # @return [String] either the path/directory portion of the file name or '(Unrecognized File)'
      #   if the offending file can't be found for some reason
      def path
        pathname.exist? ? pathname.dirname.to_s : UNRECOGNIZED
      end

      # A safe interface for getting a string representing the filename portion of the file
      #
      # @return [String] either the filename portion of the file or '(Unrecognized File)'
      #   if the offending file can't be found for some reason
      def filename
        pathname.exist? ? pathname.basename.to_s : UNRECOGNIZED
      end

      def absolute_pathname
        pathname.exist? ? pathname.to_s : UNRECOGNIZED
      end

      def relative_pathname
        pathname.exist? ? absolute_pathname.delete_prefix(Dir.pwd) : UNRECOGNIZED
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
          pathname.to_s,
          line_number: line_number,
          max_line_count: max_line_count
        )
      end

      # Determines if a given file follows the standard approaching to naming test files.
      #
      # @return [Boolean] true if the file name starts with `test_` or ends with `_test.rb`
      def test_file?
        file.to_s.start_with?('test_') || file.to_s.end_with?('_test.rb')
      end

      # A safe interface to getting the last modified time for the file in question
      #
      # @return [Time] the timestamp for when the file in question was last modified or `Time.at(0)`
      #   if the offending file can't be found for some reason
      def mtime
        pathname.exist? ? pathname.mtime : UNKNOWN_MODIFICATION_TIME
      end

      # A safe interface to getting the number of seconds since the file was modified
      #
      # @return [Integer] the number of seconds since the file was modified or `-1` if the offending
      #   file can't be found for some reason
      def age_in_seconds
        pathname.exist? ? seconds_ago : UNKNOWN_MODIFICATION_SECONDS
      end

      private

      def seconds_ago
        (Time.now - mtime).to_i
      end
    end
  end
end
