# frozen_string_literal: true

require_relative 'output/backtrace'
require_relative 'output/issue'
require_relative 'output/location'
require_relative 'output/map'
require_relative 'output/results'
require_relative 'output/source_code'
require_relative 'output/token'

module Minitest
  module Heat
    # Friendly API for printing nicely-formatted output to the console
    class Output
      FORMATTERS = {
        error: [
          [ %i[error label], %i[muted arrow], %i[default test_name] ],
          [ %i[default summary], ],
          [ %i[default backtrace_summary] ],
        ],
        broken: [
          [ %i[broken label], %i[muted spacer], %i[default test_class], %i[muted arrow], %i[default test_name] ],
          [ %i[default summary], ],
          [ %i[default backtrace_summary] ],
        ],
        failure: [
          [ %i[failure label], %i[muted spacer], %i[default test_class], %i[muted arrow], %i[default test_name], %i[muted spacer], %i[muted class] ],
          [ %i[default summary] ],
          [ %i[muted location], ],
          [ %i[default source_summary], ],
        ],
        skipped: [
          [ %i[skipped label], %i[muted spacer], %i[default test_class], %i[muted arrow], %i[default test_name] ],
          [ %i[default summary] ],
          [], # New Line
        ],
        slow: [
          [ %i[slow label], %i[muted spacer], %i[default test_class], %i[muted arrow], %i[default test_name], %i[muted spacer], %i[muted class], ],
          [ %i[bold slowness], %i[muted spacer], %i[default location], ],
          [], # New Line
        ]
      }

      attr_reader :stream

      def initialize(stream = $stdout)
        @stream = stream.tap do |str|
          # If the IO channel supports flushing the output immediately, then ensure it's enabled
          str.sync = str.respond_to?(:sync=)
        end
      end

      def print(*args)
        stream.print(*args)
      end

      def puts(*args)
        stream.puts(*args)
      end
      alias newline puts

      def marker(value)
        case value
        when 'E' then text(:error, value)
        when 'B' then text(:failure, value)
        when 'F' then text(:failure, value)
        when 'S' then text(:skipped, value)
        else          text(:success, value)
        end
      end

      def issue_details(issue)
        formatter = FORMATTERS[issue.type]

        formatter.each do |lines|
          lines.each do |tokens|
            style, content_method = *tokens

            if issue.respond_to?(content_method)
              # If it's an available method on issue, use that to get the content
              content = issue.send(content_method)
              text(style, content)
            else
              # Otherwise, fall back to output and pass issue to *it*
              send(content_method, issue)
            end
          end
          newline
        end
      end

      def heat_map(map)
        map.files.each do |file|
          file = file[0]
          values = map.hits[file]

          filename = file.split('/').last
          path = file.delete_suffix(filename)

          text(:error, 'E' * values[:error].size)     if values[:error]&.any?
          text(:broken, 'B' * values[:broken].size)   if values[:broken]&.any?
          text(:failure, 'F' * values[:failure].size) if values[:failure]&.any?

          unless values[:error]&.any? || values[:broken]&.any? || values[:failure]&.any?
            text(:skipped, 'S' * values[:skipped].size) if values[:skipped]&.any?
            text(:painful, '—' * values[:painful].size) if values[:painful]&.any?
            text(:slow, '–' * values[:slow].size)       if values[:slow]&.any?
          end

          text(:muted, ' ') if map.hits.any?

          text(:muted, "#{path.delete_prefix('/')}")
          text(:default, "#{filename}")

          text(:muted, ':')

          all_line_numbers = values.fetch(:error, []) + values.fetch(:failure, [])
          all_line_numbers += values.fetch(:skipped, [])

          line_numbers = all_line_numbers.compact.uniq.sort
          line_numbers.each { |line_number| text(:muted, "#{line_number} ") }
          newline
        end
        newline
      end

      def compact_summary(results)
        error_count = results.errors.size
        broken_count = results.brokens.size
        failure_count = results.failures.size
        slow_count = results.slows.size
        skip_count = results.skips.size

        counts = []
        counts << pluralize(error_count, 'Error') if error_count.positive?
        counts << pluralize(broken_count, 'Broken') if broken_count.positive?
        counts << pluralize(failure_count, 'Failure') if failure_count.positive?
        counts << pluralize(skip_count, 'Skip') if skip_count.positive?
        counts << pluralize(slow_count, 'Slow') if slow_count.positive?
        text(:default, counts.join(', '))

        newline
        text(:muted, "#{results.tests_per_second} tests/s and #{results.assertions_per_second} assertions/s ")

        newline
        text(:muted, pluralize(results.test_count, 'Test') + ' & ')
        text(:muted, pluralize(results.assertion_count, 'Assertion'))
        text(:muted, " in #{results.total_time.round(2)}s")

        newline
        newline
      end

      private

      def test_name_summary(issue)
        text(:default, "#{issue.test_class} > #{issue.test_name}")
      end

      def backtrace_summary(issue)
        # backtrace_lines = issue.backtrace.project_lines

        # backtrace_line = backtrace_lines.first
        # filename = "#{backtrace_line.path.delete_prefix(Dir.pwd)}/#{backtrace_line.file}"

        # backtrace_lines.take(3).each do |line|
        #   source = Minitest::Heat::Source.new("#{backtrace_line.path}/#{backtrace_line.file}", line_number: line.number, max_line_count: 1)

        #   text(:muted, "  #{line.path.delete_prefix("#{Dir.pwd}/")}/")
        #   text(:muted, "#{line.file}:#{line.number}")
        #   text(:source, " `#{source.line.strip}`")

        #   newline
        # end

        backtrace_tokens = ::Minitest::Heat::Output::Backtrace.new(issue.location).tokens
        pp backtrace_tokens.inspect
        print_tokens(backtrace_tokens)
      end

      def source_summary(issue)
        filename = issue.location.project_file
        line_number = issue.location.project_failure_line

        source_code_tokens = ::Minitest::Heat::Output::SourceCode.new(filename, line_number).tokens

        print_tokens(source_code_tokens)
      end

      def style_enabled?
        stream.tty?
      end

      def pluralize(count, singular)
        singular_style = "#{count} #{singular}"

        # Given the narrow scope, pluralization can be relatively naive here
        count > 1 ? "#{singular_style}s" : singular_style
      end

      def text(style, content)
        token = Token.new(style, content)

        token_format = style_enabled? ? :styled : :unstyled

        print token.to_s(token_format)
      end

      def print_tokens(lines_of_tokens)
        token_format = style_enabled? ? :styled : :unstyled

        lines_of_tokens.each do |tokens|
          tokens.each do |token|
            print token.to_s(token_format)
          end
          newline
        end
      end
    end
  end
end
