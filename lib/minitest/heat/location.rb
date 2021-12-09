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

      # Initialize a new Location
      #
      # @param [Pathname, String] pathname: the pathname to the file
      # @param [Integer] line_number: the line number of the location within the file
      # @param [String] container: nil the containing method or block for the issue
      #
      # @return [self]
      def initialize(pathname:, line_number:, container: nil)
        @raw_pathname = pathname
        @raw_line_number = line_number
        @raw_container = container
      end

      # Generates a formatted string describing the line of code similar to the original backtrace
      #
      # @return [String] a consistently-formatted, human-readable string about the line of code
      def to_s
        "#{absolute_path}#{filename}:#{line_number} in `#{container}`"
      end

      # Generates a simplified location array with the pathname and line number
      #
      # @return [Array<Pathname, Integer>] a no-frills location pair
      def to_a
        [
          pathname,
          line_number
        ]
      end

      # A short relative pathname and line number pair
      #
      # @return [String] the short filename/line number combo. ex. `dir/file.rb:23`
      def short
        "#{relative_filename}:#{line_number}"
      end

      # Determine if there is a file and text at the given line number
      #
      # @return [Boolean] true if the file exists and has text at the given line number
      def exists?
        pathname.exist? && source_code.lines.any?
      end

      # The pathanme for the location. Written to be safe and fallbackto the project directory if
      #   an exception is raised ocnverting the value to a pathname
      #
      # @return [Pathname] a pathname instance for the relevant file
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

      def absolute_path
        pathname.exist? ? "#{path}/" : UNRECOGNIZED
      end

      def relative_path
        pathname.exist? ? absolute_path.delete_prefix("#{project_root_dir}/") : UNRECOGNIZED
      end

      # A safe interface for getting a string representing the filename portion of the file
      #
      # @return [String] either the filename portion of the file or '(Unrecognized File)'
      #   if the offending file can't be found for some reason
      def filename
        pathname.exist? ? pathname.basename.to_s : UNRECOGNIZED
      end

      def absolute_filename
        pathname.exist? ? pathname.to_s : UNRECOGNIZED
      end

      def relative_filename
        pathname.exist? ? pathname.to_s.delete_prefix("#{project_root_dir}/") : UNRECOGNIZED
      end

      # Line number identifying the specific line in the file
      #
      # @return [Integer] line number for the file
      #
      def line_number
        Integer(raw_line_number)
      rescue ArgumentError
        1
      end

      # The containing method or block details for the location
      #
      # @return [String] the containing method of the line of code
      def container
        raw_container.nil? ? '(Unknown Container)' : String(raw_container)
      end

      # Looks up the source code for the location. Can return multiple lines of source code from
      #   the surrounding lines of code for the primary line
      #
      # @param [Integer] max_line_count: 1 the maximum number of lines to return from the source
      #
      # @return [Source] an instance of Source for accessing lines and their line numbers
      def source_code(max_line_count: 1)
        Minitest::Heat::Source.new(
          pathname.to_s,
          line_number: line_number,
          max_line_count: max_line_count
        )
      end

      # Determines if a given file is from the project directory
      #
      # @return [Boolean] true if the file is in the project (source code or test) but not vendored
      def project_file?
        path.include?(project_root_dir) && !bundled_file?
      end

      # Determines if the file is in the project `vendor/bundle` directory.
      #
      # @return [Boolean] true if the file is in `<project_root>/vendor/bundle
      def bundled_file?
        path.include?("#{project_root_dir}/vendor/bundle")
      end

      # Determines if a given file follows the standard approaching to naming test files.
      #
      # @return [Boolean] true if the file name starts with `test_` or ends with `_test.rb`
      def test_file?
        filename.to_s.start_with?('test_') || filename.to_s.end_with?('_test.rb')
      end

      # Determines if a given file is a non-test file from the project directory
      #
      # @return [Boolean] true if the file is in the project but not a test file or vendored file
      def source_code_file?
        project_file? && !test_file? && !bundled_file?
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

      def project_root_dir
        Dir.pwd
      end

      def seconds_ago
        (Time.now - mtime).to_i
      end
    end
  end
end
