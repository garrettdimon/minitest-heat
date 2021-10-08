# frozen_string_literal: true

module Minitest
  module Heat
    class Map
      MAXIMUM_FILES_TO_SHOW = 5

      attr_reader :hits

      # So we can sort hot spots by liklihood of being the most important spot to check out before
      #   trying to fix something. These are ranked based on the possibility they represent ripple
      #   effects where fixing one problem could potentially fix multiple other failures.
      #
      #   For example, if there's an exception in the file, start there. Broken code can't run. If a
      #   test is broken (i.e. raising an exception), that's a special sort of failure that would be
      #   misleading. It doesn't represent a proper failure, but rather a test that doesn't work.
      WEIGHTS = {
        error: 3,    # exceptions from source code have the highest liklihood of a ripple effect
        broken: 2,   # broken tests won't have ripple effects but can't help if they can't run
        failure: 1,  # failures are kind of the whole point, and they could have ripple effects
        skipped: 0,  # skips aren't failures, but they shouldn't go ignored
        painful: 0,  # slow tests aren't failures, but they shouldn't be ignored
        slow: 0
      }.freeze

      def initialize
        @hits = {}
      end

      def add(filename, line_number, type)
        @hits[filename] ||= Hit.new(filename)

        @hits[filename].log(type, line_number)
      end

      def file_hits
        hot_files.take(MAXIMUM_FILES_TO_SHOW)
      end

      private

      def hot_files
        hits.values.sort_by(&:weight).reverse
      end
    end
  end
end
