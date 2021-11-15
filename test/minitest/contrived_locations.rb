# Re-open these classes to add bogus methods that raise errors from inside the source rather than
#   directly from the tests. These need to be in a separate file from `contrived_examples_test.rb`
#   so Minitest::Heat doesn't perceive them as occuring from a test file since it treats exceptions
#   from test files and source files differently.
module Minitest
  module Heat
    class Locations
      def self.raise_example_error_in_location
        raise StandardError, 'Invalid Location Exception'
      end
    end
  end
end
