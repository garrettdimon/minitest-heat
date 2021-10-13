# frozen_string_literal: true

module Minitest
  module Heat
    class Output
      class Results
        extend Forwardable

        attr_accessor :results, :timer

        def_delegators :@results, :issues, :errors, :brokens, :failures, :skips, :painfuls, :slows, :problems?

        def initialize(results, timer)
          @results = results
          @timer = timer
          @tokens = []
        end

        def tokens
          # Only show the issue type counts if there are issues
          @tokens << [*issue_counts_tokens] if issue_counts_tokens&.any?

          @tokens << [
            timing_token, separator_token,
            test_count_token, tests_performance_token, separator_token,
            assertions_count_token, assertions_performance_token
          ]

          @tokens
        end

        private

        def pluralize(count, singular)
          singular_style = "#{count} #{singular}"

          # Given the narrow scope, pluralization can be relatively naive here
          count > 1 ? "#{singular_style}s" : singular_style
        end

        def issue_counts_tokens
          return unless issues.any?

          counts = [
            error_count_token,
            broken_count_token,
            failure_count_token,
            skip_count_token,
            painful_count_token,
            slow_count_token
          ].compact

          # # Create an array of separator tokens one less than the total number of issue count tokens
          separator_tokens = Array.new(counts.size, separator_token)

          counts_with_separators = counts
                                   .zip(separator_tokens) # Add separators between the counts
                                   .flatten(1) # Flatten the zipped separators, but no more

          counts_with_separators.pop # Remove the final trailing zipped separator that's not needed

          counts_with_separators
        end

        def error_count_token
          issue_count_token(:error, errors)
        end

        def broken_count_token
          issue_count_token(:broken, brokens)
        end

        def failure_count_token
          issue_count_token(:failure, failures)
        end

        def skip_count_token
          style = problems? ? :muted : :skipped
          issue_count_token(style, skips, name: 'Skip')
        end

        def painful_count_token
          style = problems? ? :muted : :painful
          issue_count_token(style, painfuls, name: 'Painfully Slow')
        end

        def slow_count_token
          style = problems? ? :muted : :slow
          issue_count_token(style, slows, name: 'Slow')
        end

        def test_count_token
          [:default, "#{pluralize(timer.test_count, 'test')}"]
        end

        def tests_performance_token
          [:default, " (#{timer.tests_per_second}/s)"]
        end

        def assertions_count_token
          [:default, "#{pluralize(timer.assertion_count, 'assertion')}"]
        end

        def assertions_performance_token
          [:default, " (#{timer.assertions_per_second}/s)"]
        end

        def timing_token
          [:bold, "#{timer.total_time.round(2)}s"]
        end

        def issue_count_token(type, collection, name: type.capitalize)
          return nil if collection.empty?

          [type, pluralize(collection.size, name)]
        end

        def separator_token
          [:muted, ' · ']
        end
      end
    end
  end
end
