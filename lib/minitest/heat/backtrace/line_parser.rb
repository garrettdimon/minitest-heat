# frozen_string_literal: true

require 'forwardable'

module Minitest
  module Heat
    class Backtrace
      # Represents a line from a backtrace to provide more convenient access to information about
      #   the relevant file and line number for displaying in test results
      module LineParser
        # Parses a line from a backtrace in order to convert it to usable components
        def self.read(raw_text)
          return nil if raw_text.nil? || raw_text.empty?

          raw_pathname, raw_line_number, raw_container = raw_text.to_s.split(':')
          raw_container = raw_container&.delete_prefix('in `')&.delete_suffix("'")

          ::Minitest::Heat::Location.new(
            pathname: raw_pathname,
            line_number: raw_line_number,
            container: raw_container
          )
        end
      end
    end
  end
end
