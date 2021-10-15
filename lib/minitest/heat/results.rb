# frozen_string_literal: true

module Minitest
  module Heat
    # A collection of test failures
    class Results
      attr_reader :issues, :heat_map

      def initialize
        @issues = []
        @heat_map = Heat::Map.new
      end

      def record(issue)
        @issues.push(issue)
        @heat_map.add(*issue.to_hit) if issue.hit?
      end

      def problems?
        errors.any? || brokens.any? || failures.any?
      end

      def errors
        @errors ||= select_issues(:error)
      end

      def brokens
        @brokens ||= select_issues(:broken)
      end

      def failures
        @failures ||= select_issues(:failure)
      end

      def skips
        @skips ||= select_issues(:skipped)
      end

      def painfuls
        @painfuls ||= select_issues(:painful).sort_by(&:time).reverse
      end

      def slows
        @slows ||= select_issues(:slow).sort_by(&:time).reverse
      end

      private

      def select_issues(issue_type)
        issues.select { |issue| issue.type == issue_type }
      end
    end
  end
end
