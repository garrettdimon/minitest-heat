# frozen_string_literal: true

require_relative 'contrived_issue'
require_relative 'contrived_locations'

# Re-open these classes to add bogus methods that raise errors from inside the source rather than
#   directly from the tests. These need to be in a separate file from `contrived_examples_test.rb`
#   so Minitest::Heat doesn't perceive them as occuring from a test file since it treats exceptions
#   from test files and source files differently.
module Minitest
  module Heat
    def self.raise_example_error
      Issue.raise_example_error_from_issue
    end

    def self.raise_another_example_error
      Issue.raise_another_example_error_from_issue
    end

    def self.increase_the_stack_level
      increase_the_stack_level_more
    end

    def self.increase_the_stack_level_more
      increase_the_stack_level_even_more
    end

    def self.increase_the_stack_level_even_more
      increase_the_stack_level
    end
  end
end
