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
      SYMBOLS = {
        middot: '·',
        arrow: '➜',
        lead: '|'
      }.freeze

      TOKENS = {
        spacer: [:muted, " #{SYMBOLS[:middot]} "],
        muted_arrow: [:muted, " #{SYMBOLS[:arrow]} "],
        muted_lead: [:muted, "#{SYMBOLS[:lead]} "]
      }.freeze

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

      def issues_list(results)
        # A couple of blank lines to create some breathing room
        newline
        newline

        # Issues start with the least critical and go up to the most critical so that the most
        #   pressing issues are displayed at the bottom of the report in order to reduce scrolling.
        #   This way, as you fix issues, the list gets shorter, and eventually the least critical
        #   issues will be displayed without scrolling once more problematic issues are resolved.
        %i[slows painfuls skips failures brokens errors].each do |issue_category|
          next unless show?(issue_category, results)

          results.send(issue_category).each { |issue| issue_details(issue) }
        end
      rescue => e
        message = "Sorry, but Minitest Heat couldn't display the details of any failures."
        exception_guidance(message, e)
      end

      def issue_details(issue)
        print_tokens Minitest::Heat::Output::Issue.new(issue).tokens
      rescue => e
        message = "Sorry, but Minitest Heat couldn't display output for a failure."
        exception_guidance(message, e)
      end

      def marker(issue_type)
        print_token Minitest::Heat::Output::Marker.new(issue_type).token
      end

      def compact_summary(results, timer)
        newline
        print_tokens ::Minitest::Heat::Output::Results.new(results, timer).tokens
      rescue => e
        message = "Sorry, but Minitest Heat couldn't display the summary."
        exception_guidance(message, e)
      end

      def heat_map(map)
        newline
        print_tokens ::Minitest::Heat::Output::Map.new(map).tokens
        newline
      rescue => e
        message = "Sorry, but Minitest Heat couldn't display the heat map."
        exception_guidance(message, e)
      end

      def exception_guidance(message, exception)
        newline
        puts "#{message} Disabling Minitest Heat can get you back on track until the problem can be fixed."
        puts "Please use the following exception details to submit an issue at https://github.com/garrettdimon/minitest-heat/issues"
        puts "#{exception.message}:"
        exception.backtrace.each do |line|
          puts "  #{line}"
        end
        newline
      end

      private

      def no_problems?(results)
        !results.problems?
      end

      def no_problems_or_skips?(results)
        !results.problems? && results.skips.none?
      end

      def show?(issue_category, results)
        case issue_category
        when :skips            then no_problems?(results)
        when :painfuls, :slows then no_problems_or_skips?(results)
        else true
        end
      end

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
