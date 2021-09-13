# frozen_string_literal: true

module Minitest
  module Heat
    # Wrapper for separating backtrace into component parts
    class Backtrace
      Line = Struct.new(:path, :file, :number, :container, :mtime, keyword_init: true) do
        def to_s
          "#{location} in `#{container}`"
        end

        def pathname
          Pathname("#{path}/#{file}")
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
      end

      UNREADABLE_FILE_ATTRIBUTES = {
        path: '(Unknown Path)',
        file: '(Unknown File)',
        number: '(Unknown Line Number)',
        container: '(Unknown Method)',
        mtime: '(Unknown Modification Time)'
      }

      UNREADABLE_LINE = Line.new(UNREADABLE_FILE_ATTRIBUTES)

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
        @project_lines ||= parsed_lines.select { |line| line[:path].include?(Dir.pwd) }
      end

      def recently_modified_lines
        @recently_modified_lines ||= project_lines.sort_by { |line| line[:mtime] }.reverse
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

      def reduce_container(container)
        container.delete_prefix('in `').delete_suffix("'")
      end

      def parse(line)
        Line.new(line_attributes(line))
      end

      def line_attributes(line)
        parts = line.split(':')
        pathname = Pathname.new(parts[0])

        {
          path: pathname.dirname.to_s,
          file: pathname.basename.to_s,
          number: parts[1],
          container: reduce_container(parts[2]),
          mtime: pathname.exist? ? pathname.mtime : nil
        }
      rescue
        UNREADABLE_FILE_ATTRIBUTES
      end

      def test_file?(line)
        line[:file].end_with?('_test.rb') || line[:file].start_with?('test_')
      end
    end
  end
end
