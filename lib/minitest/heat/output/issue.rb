# frozen_string_literal: true

module Minitest
  module Heat
    class Output
      # Formats issues to output based on the issue type
      class Issue # rubocop:disable Metrics/ClassLength
        attr_accessor :issue, :locations

        def initialize(issue)
          @issue = issue
          @locations = issue.locations
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
          [label_token(issue), spacer_token, [:default, test_name(issue)]]
        end

        def test_name(issue)
          test_prefix = 'test_'
          identifier = issue.test_identifier

          if identifier.start_with?(test_prefix)
            identifier.delete_prefix(test_prefix).gsub('_', ' ').capitalize
          else
            identifier
          end
        end

        def label_token(issue)
          [issue.type, issue_label(issue.type)]
        end

        def issue_label(issue_type)
          case issue_type
          when :error   then 'Error'
          when :broken  then 'Broken Test'
          when :failure then 'Failure'
          when :skipped then 'Skipped'
          when :slow    then 'Passed but Slow'
          when :painful then 'Passed but Very Slow'
          when :passed  then 'Success'
          else 'Unknown'
          end
        end

        def test_name_and_class_tokens
          [[:default, issue.test_class], *test_location_tokens]
        end

        def backtrace_tokens
          @backtrace_tokens ||= ::Minitest::Heat::Output::Backtrace.new(locations).tokens
        end

        def test_location_tokens
          [
            [:default, locations.test_definition.relative_filename],
            [:muted, ':'],
            [:default, locations.test_definition.line_number],
            arrow_token,
            [:default, locations.test_failure.line_number],
            [:muted, "\n  #{locations.test_failure.source_code.line.strip}"]
          ]
        end

        def location_tokens
          [
            [:default, locations.most_relevant.relative_filename],
            [:muted, ':'],
            [:default, locations.most_relevant.line_number],
            [:muted, "\n  #{locations.most_relevant.source_code.line.strip}"]
          ]
        end

        def source_tokens
          filename    = locations.project.filename
          line_number = locations.project.line_number
          source = Minitest::Heat::Source.new(filename, line_number: line_number)

          [[:muted, " #{Output::SYMBOLS[:arrow]} `#{source.line.strip}`"]]
        end

        def summary_tokens
          [[:italicized, issue.summary.delete_suffix('---------------').strip]]
        end

        def slowness_summary_tokens
          [
            [:bold, slowness(issue)],
            spacer_token,
            [:default, locations.test_definition.relative_path],
            [:default, locations.test_definition.filename],
            [:muted, ':'],
            [:default, locations.test_definition.line_number]
          ]
        end

        def slowness(issue)
          "#{issue.execution_time.round(2)}s"
        end

        def newline_tokens
          []
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
