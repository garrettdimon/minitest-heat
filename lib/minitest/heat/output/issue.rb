# frozen_string_literal: true

module Minitest
  module Heat
    class Output
      class Issue
        SHARED_SYMBOLS = {
          spacer: ' · ',
          arrow: ' > '
        }.freeze

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
          when :slow then slow_tokens
          else
          end
        end

        private

        def error_tokens
          [
            headline_tokens,
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
            summary_tokens,
            location_tokens,
            *source_tokens,
            newline_tokens
          ]
        end

        def skipped_tokens
          [
            headline_tokens,
            summary_tokens,
            newline_tokens
          ]
        end

        def slow_tokens
          [
            headline_tokens,
            slowness_tokens,
            newline_tokens
          ]
        end

        def headline_tokens
          [ [issue.type, issue.label], [:muted, spacer], [:default, issue.test_name], [:muted, spacer], [:muted, issue.test_class] ]
        end

        def summary_tokens
          [ [:italicized, issue.summary] ]
        end

        def backtrace_tokens
          backtrace = ::Minitest::Heat::Output::Backtrace.new(issue.location)

          backtrace.tokens
        end

        def location_tokens
          [ [:muted, issue.short_location] ]
        end

        def source_tokens
          filename    = issue.location.project_file
          line_number = issue.location.project_failure_line

          source_code = ::Minitest::Heat::Output::SourceCode.new(filename, line_number)

          source_code.tokens
        end

        def slowness_tokens
          [ [:bold, issue.slowness], [:muted, spacer], [:default, issue.location] ]
        end

        def newline_tokens
          []
        end

        def spacer
          SHARED_SYMBOLS[:spacer]
        end

        def arrow
          SHARED_SYMBOLS[:arrow]
        end
      end
    end
  end
end
