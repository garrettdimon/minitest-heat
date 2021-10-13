# frozen_string_literal: true

module Minitest
  module Heat
    class Output
      class Issue
        attr_accessor :issue

        def initialize(issue)
          @issue = issue
        end

        def tokens
          case issue.type
          when :error then error_tokens
          when :broken then broken_tokens
          when :failure then failure_tokens
          when :skipped then skipped_tokens
          when :painful then painful_tokens
          when :slow then slow_tokens
          end
        end

        private

        def error_tokens
          [
            headline_tokens,
            test_location_tokens,
            summary_tokens,
            *backtrace_tokens,
            newline_tokens
          ]
        end

        def broken_tokens
          [
            headline_tokens,
            summary_tokens,
            *backtrace_tokens,
            newline_tokens
          ]
        end

        def failure_tokens
          [
            headline_tokens,
            *failure_summary_tokens,
            test_location_tokens,
            *source_tokens,
            newline_tokens
          ]
        end

        def skipped_tokens
          [
            headline_tokens,
            test_location_tokens,
            summary_tokens,
            newline_tokens
          ]
        end

        def painful_tokens
          [
            headline_tokens,
            slowness_summary_tokens,
            newline_tokens
          ]
        end

        def slow_tokens
          [
            headline_tokens,
            slowness_summary_tokens,
            newline_tokens
          ]
        end

        def headline_tokens
          [[issue.type, issue.label], spacer_token, [:default, issue.test_name]]
        end

        def test_name_and_class_tokens
          [[:default, issue.test_class], *test_location_tokens ]
        end

        def backtrace_tokens
          backtrace = ::Minitest::Heat::Output::Backtrace.new(issue.location)

          backtrace.tokens
        end

        def test_location_tokens
          [[:default, test_file_short_location], [:muted, ':'], [:default, issue.test_definition_line], arrow_token, [:default, issue.test_failure_line]]
        end

        def location_tokens
          [[:muted, issue.short_location]]
        end

        def source_tokens
          filename    = issue.location.project_file
          line_number = issue.location.project_failure_line

          source_code = ::Minitest::Heat::Output::SourceCode.new(filename, line_number, max_line_count: 3)

          source_code.tokens
        end

        def summary_tokens
          [[:italicized, issue.summary]]
        end

        def slowness_summary_tokens
          [[:bold, issue.slowness], spacer_token, [:default, issue.short_location]]
        end

        def newline_tokens
          []
        end

        def test_file_short_location
          issue.location.test_file.to_s.delete_prefix("#{Dir.pwd}/")
        end

        def failure_summary_tokens
          return unless issue_summary_lines.any?

          # Sometimes, the exception message is multiple lines, so this adjusts the lines to
          # visually group them together a bit
          # if issue_summary_lines.one?
          #   [[[:italicized, issue_summary_lines.first]]]
          # else
            issue_summary_lines.map do |line|
              [Output::TOKENS[:muted_lead], [:italicized, line]]
            end
          # end
        end

        def issue_summary_lines
          @issue_summary_lines ||= issue.summary.split("\n")
        end

        def spacer_token
          Output::TOKENS[:spacer]
        end

        def arrow_token
          Output::TOKENS[:muted_arrow]
        end

      end
    end
  end
end
