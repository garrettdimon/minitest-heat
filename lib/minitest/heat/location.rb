# frozen_string_literal: true

module Minitest
  module Heat
    class Location
      attr_reader :test_location, :backtrace

      def initialize(test_location, backtrace = [])
        @test_location = test_location
        @backtrace = Backtrace.new(backtrace)
      end

      def to_s
        "#{source_file}:#{source_failure_line}"
      end

      def failure_in_test?
        !test_file.nil? && test_file == source_file
      end

      def failure_in_source?
        !failure_in_test?
      end

      def test_file
        reduced_path(test_location[0])
      end

      def test_definition_line
        test_location[1].to_s
      end

      def test_failure_line
        @backtrace.final_test_location.number
      end

      def source_file
        return test_file if backtrace.empty?

        source_line = backtrace.final_project_location || backtrace.final_location

        reduced_path("#{source_line.path}/#{source_line.file}")
      end

      def source_failure_line
        return test_definition_line if backtrace.empty?

        backtrace.final_project_location.number
      end

      private

      def reduced_path(path)
        path.delete_prefix(Dir.pwd)
      end
    end
  end
end


