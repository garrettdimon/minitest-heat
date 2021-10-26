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
            test_location_tokens,
            summary_tokens,
            *backtrace_tokens,
            newline_tokens
          ]
        end

        def failure_tokens
          [
            headline_tokens,
            test_location_tokens,
            summary_tokens,
            newline_tokens
          ]
        end

        def skipped_tokens
          [
            headline_tokens,
            test_location_tokens,
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
          [[:default, test_file_short_location], [:muted, ':'], [:default, issue.test_definition_line], arrow_token, [:default, issue.test_failure_line], [:muted, test_line_source]]
        end

        def location_tokens
          [[:default, most_relevant_short_location], [:muted, ':'], [:default, issue.location.most_relevant_failure_line], [:muted, most_relevant_line_source]]
        end

        def source_tokens
          filename    = issue.location.project_file
          line_number = issue.location.project_failure_line

          source = Minitest::Heat::Source.new(filename, line_number: line_number)
          [[:muted, " #{Output::SYMBOLS[:arrow]} `#{source.line.strip}`"]]
        end

        def summary_tokens
          [[:italicized, issue.summary.delete_suffix("---------------")]]
        end

        def slowness_summary_tokens
          [
            [:bold, issue.slowness],
            spacer_token,
            [:default, issue.location.test_file.to_s.delete_prefix(Dir.pwd)],
            [:muted, ':'],
            [:default, issue.location.test_definition_line]
          ]
        end

        def newline_tokens
          []
        end

        def most_relevant_short_location
          issue.location.most_relevant_file.to_s.delete_prefix("#{Dir.pwd}/")
        end

        def test_file_short_location
          issue.location.test_file.to_s.delete_prefix("#{Dir.pwd}/")
        end

        def most_relevant_line_source
          filename    = issue.location.project_file
          line_number = issue.location.project_failure_line

          source = Minitest::Heat::Source.new(filename, line_number: line_number)
          "\n  #{source.line.strip}"
        end

        def test_line_source
          filename    = issue.location.test_file
          line_number = issue.location.test_failure_line

          source = Minitest::Heat::Source.new(filename, line_number: line_number)
          "\n  #{source.line.strip}"
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
