# frozen_string_literal: true

module Minitest
  module Heat
    # Wrapper for separating backtrace into component parts
    class Backtrace
      # Struct for breaking a backtrace line into component parts so they're usable
      Entry = Struct.new(:raw_text) do
        def to_h
          {
            pathname: pathname.to_s,
            number: number,
            container: container,
          }
        end

        def pathname
          Pathname(raw_pathname)
        end

        def path
          pathname.dirname
        end

        def file
          pathname.basename
        end

        def line_number
          Integer(raw_line_number)
        end

        def container
          raw_container
            .delete_prefix('in `')
            .delete_suffix("'")
        end

        def mtime
          pathname.mtime
        end

        private

        def raw_pathname
          components[0]
        end

        def raw_line_number
          components[1]
        end

        def raw_container
          components[2]
        end

        def components
          @comonents ||= raw_text.split(':')
        end
      end

      attr_reader :raw_backtrace

      def initialize(raw_backtrace)
        @raw_backtrace = raw_backtrace
      end

      def empty?
        raw_backtrace.nil? || raw_backtrace.empty?
      end

      def final_location
        parsed_lines.first
      end

      def final_project_location
        project_lines.first
      end

      def freshest_project_location
        recently_modified_lines.first
      end

      def final_source_code_location
        source_code_lines.first
      end

      def final_test_location
        test_lines.first
      end

      def project_lines
        @project_lines ||= parsed_lines.select { |line| line.path.to_s.include?(Dir.pwd) }
      end

      def recently_modified_lines
        @recently_modified_lines ||= project_lines.sort_by { |line| line.mtime }.reverse
      end

      def test_lines
        @tests_lines ||= project_lines.select { |line| test_file?(line) }
      end

      def source_code_lines
        @source_code_lines ||= project_lines - test_lines
      end

      def parsed_lines
        return [] if raw_backtrace.nil?

        @parsed_lines ||= raw_backtrace.map { |line| parse(line) }
      end

      private

      def parse(line)
        Entry.new(line)
      end

      def test_file?(line)
        line.file.to_s.end_with?('_test.rb') || line.file.to_s.start_with?('test_')
      end
    end
  end
end
