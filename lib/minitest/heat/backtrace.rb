# frozen_string_literal: true

module Minitest
  module Heat
    # Wrapper for separating backtrace into component parts
    class Backtrace
      attr_reader :raw_backtrace

      def initialize(raw_backtrace)
        @raw_backtrace = raw_backtrace
      end

      def empty?
        raw_backtrace.nil? || raw_backtrace.empty?
      end

      def final_location
        parsed_entries.first
      end

      def final_project_location
        project_entries.first
      end

      def freshest_project_location
        recently_modified_entries.first
      end

      def final_source_code_location
        source_code_entries.first
      end

      def final_test_location
        test_entries.first
      end

      def project_entries
        @project_entries ||= parsed_entries.select { |entry| entry.path.to_s.include?(Dir.pwd) }
      end

      def recently_modified_entries
        @recently_modified_entries ||= project_entries.sort_by(&:mtime).reverse
      end

      def test_entries
        @tests_entries ||= project_entries.select { |entry| test_file?(entry) }
      end

      def source_code_entries
        @source_code_entries ||= project_entries - test_entries
      end

      def parsed_entries
        return [] if raw_backtrace.nil?

        @parsed_entries ||= raw_backtrace.map { |entry| Line.parse_backtrace(entry) }
      end

      private

      def parse(entry)
        Line.parse_backtrace(entry)
      end

      def test_file?(entry)
        entry.file.to_s.end_with?('_test.rb') || entry.file.to_s.start_with?('test_')
      end
    end
  end
end
