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

      # Logs an issue to the results for later reporting
      # @param issue [Issue] the issue generated from a given test result
      #
      # @return [type] [description]
      def record(issue)
        # Record everything—even if it's a success
        @issues.push(issue)

        # If it's not a genuine problem, we're done here, otherwise update the heat map
        update_heat_map(issue) if issue.hit?
      end

      def update_heat_map(issue)
        # Get the elements we need to generate a heat map entry
        pathname    = issue.location.project_file.to_s
        line_number = issue.location.project_failure_line.to_i

        @heat_map.add(pathname, line_number, issue.type)
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
        @painfuls ||= select_issues(:painful).sort_by(&:execution_time).reverse
      end

      def slows
        @slows ||= select_issues(:slow).sort_by(&:execution_time).reverse
      end

      private

      def select_issues(issue_type)
        issues.select { |issue| issue.type == issue_type }
      end
    end
  end
end
