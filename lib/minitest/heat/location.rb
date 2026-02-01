# frozen_string_literal: true

require 'pathname'

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
      def to_s = "#{absolute_path}#{filename}:#{line_number} in `#{container}`"

      # Generates a simplified location array with the pathname and line number
      #
      # @return [Array<Pathname, Integer>] a no-frills location pair
      def to_a = [pathname, line_number]

      # Generates a hash representation for JSON serialization
      #
      # @return [Hash] location data with file, line, and container
      def to_h
        {
          file: relative_filename,
          line: line_number,
          container: container
        }
      end

      # A short relative pathname and line number pair
      #
      # @return [String] the short filename/line number combo. ex. `dir/file.rb:23`
      def short = "#{relative_filename}:#{line_number}"

      # Determine if the file exists on disk
      #
      # @return [Boolean] true if the file exists
      def file_exists? = pathname.exist?

      # Determine if there is a file and text at the given line number
      #
      # @return [Boolean] true if the file exists and has text at the given line number
      def exists? = file_exists? && source_code.lines.any?

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
      def path = file_exists? ? pathname.dirname.to_s : UNRECOGNIZED

      def absolute_path = file_exists? ? "#{path}/" : UNRECOGNIZED

      def relative_path = file_exists? ? absolute_path.delete_prefix("#{project_root_dir}/") : UNRECOGNIZED

      # A safe interface for getting a string representing the filename portion of the file
      #
      # @return [String] either the filename portion of the file or '(Unrecognized File)'
      #   if the offending file can't be found for some reason
      def filename = file_exists? ? pathname.basename.to_s : UNRECOGNIZED

      def absolute_filename = file_exists? ? pathname.to_s : UNRECOGNIZED

      def relative_filename = file_exists? ? pathname.to_s.delete_prefix("#{project_root_dir}/") : UNRECOGNIZED

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
      def container = raw_container.nil? ? '(Unknown Container)' : String(raw_container)

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
      def project_file? = path.include?(project_root_dir) && !bundled_file? && !binstub_file?

      # Determines if the file is in the project `vendor/bundle` directory.
      #
      # @return [Boolean] true if the file is in `<project_root>/vendor/bundle
      def bundled_file? = path.include?("#{project_root_dir}/vendor/bundle")

      # Determines if the file is in the project `bin` directory. With binstub'd gems, they'll
      #   appear to be source code because the code is located in the project directory. This helps
      #   make sure the backtraces don't think that's the case
      #
      # @return [Boolean] true if the file is in `<project_root>/bin
      def binstub_file? = path.include?("#{project_root_dir}/bin")

      # Determines if a given file follows the standard approaching to naming test files.
      #
      # @return [Boolean] true if the file name starts with `test_` or ends with `_test.rb`
      def test_file? = filename.to_s.start_with?('test_') || filename.to_s.end_with?('_test.rb')

      # Determines if a given file is a non-test file from the project directory
      #
      # @return [Boolean] true if the file is in the project but not a test file or vendored file
      def source_code_file? = project_file? && !test_file?

      # A safe interface to getting the last modified time for the file in question
      #
      # @return [Time] the timestamp for when the file in question was last modified or `Time.at(0)`
      #   if the offending file can't be found for some reason
      def mtime = file_exists? ? pathname.mtime : UNKNOWN_MODIFICATION_TIME

      # A safe interface to getting the number of seconds since the file was modified
      #
      # @return [Integer] the number of seconds since the file was modified or `-1` if the offending
      #   file can't be found for some reason
      def age_in_seconds = file_exists? ? seconds_ago : UNKNOWN_MODIFICATION_SECONDS

      private

      def project_root_dir = Dir.pwd

      def seconds_ago = (Time.now - mtime).to_i
    end
  end
end
