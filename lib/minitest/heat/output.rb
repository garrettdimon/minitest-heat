# frozen_string_literal: true

require_relative 'output/backtrace'
require_relative 'output/issue'
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

      def issue_details(issue)
        issue_details_lines = Minitest::Heat::Output::Issue.new(issue).tokens

        print_tokens(issue_details_lines)
      end

      def marker(issue_type)
        marker_token = Minitest::Heat::Output::Marker.new(issue_type).token

        print_token(marker_token)
      end

      def compact_summary(results)
        results_tokens = ::Minitest::Heat::Output::Results.new(results).tokens

        newline
        print_tokens(results_tokens)
        newline
      end

      def heat_map(map)
        map_tokens = ::Minitest::Heat::Output::Map.new(map).tokens

        newline
        print_tokens(map_tokens)
        newline
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
