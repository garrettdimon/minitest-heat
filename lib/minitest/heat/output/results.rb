# frozen_string_literal: true

module Minitest
  module Heat
    class Output
      class Results
        extend Forwardable

        attr_accessor :results

        def_delegators :@results, :errors, :brokens, :failures, :slows, :skips, :problems?, :slows?

        def initialize(results)
          @results = results
          @tokens = []
        end

        def tokens
          @tokens << [*issue_counts_tokens] if issue_counts_tokens&.any?
          @tokens << [assertions_count_token, test_count_token]
          @tokens << [assertions_performance_token, tests_performance_token, timing_token]

          @tokens
        end

        private

        def pluralize(count, singular)
          singular_style = "#{count} #{singular}"

          # Given the narrow scope, pluralization can be relatively naive here
          count > 1 ? "#{singular_style}s" : singular_style
        end

        def issue_counts_tokens
          return unless problems? || slows?

          counts = [error_count_token, broken_count_token, failure_count_token, skip_count_token, slow_count_token].compact

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

        def slow_count_token
          style = problems? ? :muted : :slow
          issue_count_token(style, slows, name: 'Slow')
        end

        def assertions_performance_token
          [:bold, "#{results.assertions_per_second} assertions/s"]
        end

        def tests_performance_token
          [:default, " and #{results.tests_per_second} tests/s"]
        end

        def timing_token
          [:default, " in #{results.total_time.round(2)}s"]
        end

        def assertions_count_token
          [:muted, pluralize(results.assertion_count, 'Assertion')]
        end

        def test_count_token
          [:muted, " across #{pluralize(results.test_count, 'Test')}"]
        end

        def issue_count_token(type, collection, name: type.capitalize)
          return nil if collection.empty?

          [type, pluralize(collection.size, name)]
        end

        def separator_token
          [:muted, ', ']
        end
      end
    end
  end
end
