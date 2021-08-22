# frozen_string_literal: true

module Minitest
  module Heat
    class Location
      attr_reader :test_location, :backtrace

      def initialize(test_location, backtrace)
        @test_location = test_location
        @backtrace = Backtrace.new(backtrace)
      end

      def self.raise_example_error_in_location
        raise StandardError.new('Invalid Location Exception') if ENV['FORCE_FAILURES']
      end

      def failure_in_test?
        test_file == source_file
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
        source_line = backtrace.final_project_location

        reduced_path("#{source_line.path}/#{source_line.file}")
      end

      def source_failure_line
        backtrace.final_project_location.number
      end

      def project_directory_name
        Dir.pwd.split('/').last
      end

      private

      def reduced_path(path)
        "/#{path.split("/#{project_directory_name}/").last}"
      end
    end
  end
end


