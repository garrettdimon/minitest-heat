# frozen_string_literal: true

module Minitest
  module Heat
    # Wrapper for separating backtrace into component parts
    class Backtrace
      Line = Struct.new(:path, :file, :number, :container, :mtime, keyword_init: true) do
        def to_s
          "#{path}/#{file}:#{line} in `#{container}` #{age_in_seconds}"
        end

        def to_file
          "#{path}/#{file}"
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
        parsed.first
      end

      def final_project_location
        project.first
      end

      def final_test_location
        tests.first
      end

      def freshest_project_location
        recently_modified.first
      end

      def project
        @project ||= parsed.select { |line| line[:path].include?(Dir.pwd) }
      end

      def tests
        @tests ||= project.select { |line| test_file?(line) }
      end

      def recently_modified
        @recently_modified ||= project.sort_by { |line| line[:mtime] }.reverse
      end

      def parsed
        return [] if raw_backtrace.nil?

        @parsed ||= raw_backtrace.map { |line| parse(line) }
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
