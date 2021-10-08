# frozen_string_literal: true

require 'forwardable'

module Minitest
  module Heat
    # Kind of like an issue, but instead of focusing on a failing test, it covers all issues for a
    #   given file
    class Hit
      # So we can sort hot spots by liklihood of being the most important spot to check out before
      #   trying to fix something. These are ranked based on the possibility they represent ripple
      #   effects where fixing one problem could potentially fix multiple other failures.
      #
      #   For example, if there's an exception in the file, start there. Broken code can't run. If a
      #   test is broken (i.e. raising an exception), that's a special sort of failure that would be
      #   misleading. It doesn't represent a proper failure, but rather a test that doesn't work.
      WEIGHTS = {
        error: 3,    # exceptions from source code have the highest likelihood of a ripple effect
        broken: 2,   # broken tests won't have ripple effects but can't help if they can't run
        failure: 1,  # failures are kind of the whole point, and they could have ripple effects
        skipped: 0,  # skips aren't failures, but they shouldn't go ignored
        painful: 0,  # slow tests aren't failures, but they shouldn't be ignored
        slow: 0,
      }

      attr_reader :pathname, :issues

      def initialize(pathname)
        @pathname = Pathname(pathname)
        @issues = {}
      end

      def log(type, line_number)
        @issues[type] ||= []
        @issues[type] << line_number
      end

      def mtime
        pathname.mtime
      end

      def age_in_seconds
        (Time.now - mtime).to_i
      end

      def critical_issues?
        issues[:error].any? || issues[:broken].any? || issues[:failure].any?
      end

      def issue_count
        count = 0
        Issue::TYPES.each do |issue_type|
          count += issues.fetch(issue_type) { [] }.size
        end
        count
      end

      def weight
        weight = 0
        issues.each_pair do |type, values|
          weight += values.size * WEIGHTS.fetch(type) { 0 }
        end
        weight
      end

      def count
        count = 0
        issues.each_pair do |type, values|
          count += values.size
        end
        count
      end

      def line_numbers
        line_numbers = []
        issues.each_pair do |type, values|
          line_numbers += values
        end
        line_numbers.uniq.sort
      end
    end
  end
end
