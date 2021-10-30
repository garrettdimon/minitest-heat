# frozen_string_literal: true

if ENV['FORCE_EXCEPTIONS'] || ENV['IMPLODE']
  # Re-open these classes to add bogus methods that raise errors from inside the source rather than
  #   directly from the tests. These need to be in a separate file from
  #   `contrived_exceptions_test.rb` so Minitest::Heat doesn't perceive them as occuring from a test
  #   file since it treats exceptions from test files and source files differently.
  module Minitest
    module Heat
      def self.raise_example_error
        Issue.raise_example_error_from_issue
      end

      def self.raise_another_example_error
        Issue.raise_another_example_error_from_issue
      end

      class Issue
        def self.raise_example_error_from_issue
          Location.raise_example_error_in_location
        end

        def self.raise_another_example_error_from_issue
          Location.raise_example_error_in_location
        end
      end

      class Location
        def self.raise_example_error_in_location
          raise StandardError, 'Invalid Location Exception'
        end
      end
    end
  end
end
