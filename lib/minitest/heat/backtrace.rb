# frozen_string_literal: true

module Minitest
  module Heat
    # Wrapper for separating backtrace into component parts
    class Backtrace
      Line = Struct.new(:path, :file, :number, :container, :mtime, keyword_init: true) do
        def to_s
          "#{to_location} in `#{container}`"
        end

        def to_file
          "#{path}/#{file}"
        end

        def to_location
          "#{to_file}:#{number}"
        end

        def age_in_seconds
          (Time.now - mtime).to_i
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
      end

      def test_file?(line)
        line[:file].end_with?('_test.rb') || line[:file].start_with?('test_')
      end
    end
  end
end
