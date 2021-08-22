# frozen_string_literal: true

module Minitest
  module Heat
    class Map
      attr_reader :locations

      # {
      #   'Module::ClassName' => {
      #     'test' => {
      #       file: 'dir/path/file_test.rb'
      #     },
      #     'lines' => {
      #       23 => {
      #         errors: 3,
      #         failures: 2,
      #         skips: 0
      #       },
      #       36 => {
      #         errors: 10,
      #         failures: 2,
      #         skips: 0
      #       },
      #     }
      #   }
      # }

      def initialize
        @locations = []
      end

      def add(result)
      end
    end
  end
end
