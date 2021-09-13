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
          [ %i[error label], %i[muted spacer], %i[default test_name] ],
          [ %i[italicized summary], ],
          [ %i[default backtrace_summary] ],
        ],
        broken: [
          [ %i[broken label], %i[muted spacer], %i[default test_name], %i[muted spacer], %i[muted test_class] ],
          [ %i[italicized summary], ],
          [ %i[default backtrace_summary] ],
        ],
        failure: [
          [ %i[failure label], %i[muted spacer], %i[default test_name], %i[muted spacer], %i[muted test_class] ],
          [ %i[italicized summary] ],
          [ %i[muted short_location], ],
          [ %i[default source_summary], ],
        ],
        skipped: [
          [ %i[skipped label], %i[muted spacer], %i[default test_name], %i[muted spacer], %i[muted test_class] ],
          [ %i[italicized summary] ],
          [], # New Line
        ],
        slow: [
          [ %i[slow label], %i[muted spacer], %i[default test_name], %i[muted spacer], %i[default test_class] ],
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

      # TOOD: Convert to output class
      #       - This should likely live in the output/issue class
      #       - Add a 'fail_fast' option that shows the issue as soon as the failure occurs
      def marker(value)
        case value
        when 'E' then text(:error, value)
        when 'B' then text(:failure, value)
        when 'F' then text(:failure, value)
        when 'S' then text(:skipped, value)
        else          text(:success, value)
        end
      end

      # TOOD: Convert to output class
      #       - This should likely live in the output/issue class
      #       - There may be justification for creating different "strategies" for the various types
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

      # TOOD: Convert to output class
      def heat_map(map)
        map.files.each do |file|
          pathname = Pathname(file[0])

          path = pathname.dirname.to_s
          filename = pathname.basename.to_s

          values = map.hits[pathname.to_s]


          text(:error, 'E' * values[:error].size)     if values[:error]&.any?
          text(:broken, 'B' * values[:broken].size)   if values[:broken]&.any?
          text(:failure, 'F' * values[:failure].size) if values[:failure]&.any?

          unless values[:error]&.any? || values[:broken]&.any? || values[:failure]&.any?
            text(:skipped, 'S' * values[:skipped].size) if values[:skipped]&.any?
            text(:painful, '—' * values[:painful].size) if values[:painful]&.any?
            text(:slow, '–' * values[:slow].size)       if values[:slow]&.any?
          end

          text(:muted, ' ') if map.hits.any?

          text(:muted, "#{path.delete_prefix(Dir.pwd)}/")
          text(:default, filename)

          text(:muted, ':')

          all_line_numbers = values.fetch(:error, []) + values.fetch(:failure, [])
          all_line_numbers += values.fetch(:skipped, [])

          line_numbers = all_line_numbers.compact.uniq.sort
          line_numbers.each { |line_number| text(:muted, "#{line_number} ") }
          newline
        end
        newline
      end

      # TOOD: Convert to output class
      def test_name_summary(issue)
        text(:default, "#{issue.test_class} > #{issue.test_name}")
      end

      def compact_summary(results)
        results_tokens = ::Minitest::Heat::Output::Results.new(results).tokens

        newline
        print_tokens(results_tokens)
        newline
      end

      def backtrace_summary(issue)
        location = issue.location

        backtrace_tokens = ::Minitest::Heat::Output::Backtrace.new(location).tokens
        print_tokens(backtrace_tokens)
      end

      def source_summary(issue)
        filename    = issue.location.project_file
        line_number = issue.location.project_failure_line

        source_code_tokens = ::Minitest::Heat::Output::SourceCode.new(filename, line_number).tokens
        print_tokens(source_code_tokens)
      end

      private

      def style_enabled?
        stream.tty?
      end

      def text(style, content)
        token = Token.new(style, content)
        print token.to_s(token_format)
      end

      def token_format
        style_enabled? ? :styled : :unstyled
      end

      def print_tokens(lines_of_tokens)
        lines_of_tokens.each do |tokens|
          tokens.each do |token|
            print Token.new(*token).to_s(token_format)
          end
          newline
        end
      end
    end
  end
end
