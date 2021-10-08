# frozen_string_literal: true

require_relative 'output/backtrace'
require_relative 'output/issue'
require_relative 'output/location'
require_relative 'output/map'
require_relative 'output/marker'
require_relative 'output/results'
require_relative 'output/source_code'
require_relative 'output/token'

module Minitest
  module Heat
    # Friendly API for printing nicely-formatted output to the console
    class Output
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
      #       - There may be justification for creating different "strategies" for the various types
      FORMATTERS = {
        error: [
          [ %i[error label], %i[muted spacer], %i[default test_name], %i[muted spacer], %i[muted test_class] ],
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

      def marker(issue_type)
        marker_token = Minitest::Heat::Output::Marker.new(issue_type).token

        print_token(marker_token)
      end

      def heat_map(map)
        map_tokens = ::Minitest::Heat::Output::Map.new(map).tokens

        newline
        # pp map_tokens
        print_tokens(map_tokens)
        newline
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

      def print_token(token)
        print Token.new(*token).to_s(token_format)
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
