# frozen_string_literal: true

require 'diffy'

module Minitest
  module Heat
    # Friendly API for printing nicely-formatted output to the console
    class Output
      SPACER = ' · '

      RED           = '0;31'
      GREEN         = '0;32'
      GRAY          = '0;37'
      DARK_GRAY     = '1;30'
      LIGHT_RED     = '1;31'
      LIGHT_GREEN   = '1;32'
      YELLOW        = '1;33'
      WHITE         = '1;37'
      BOLD          = '1'
      NOT_BOLD      = '21'


      RESET = "\e[0m"

      COLORS = {
        default: 39,
        red: 31,
        green: 32,
        yellow: 33,
        gray: 37,
        white: 97
      }.freeze

      WEIGHTS = {
        default: 0,
        bold: 1,
        light: 2
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

      def marker(value)
        case value
        when 'E' then error_style(value)
        when 'F' then failure_style(value)
        when 'S' then skipped_style(value)
        else          success_style(value)
        end
      end

      def issue_formatter(issue)

      end

      def issue_details(issue)
        if issue.error?
          error_formatter(issue)
        elsif issue.skipped?
          skipped_formatter(issue)
        elsif !issue.passed?
          failure_formatter(issue)
        elsif issue.turtle?
          turtle_formatter(issue)
        end
      end

      def error_formatter(issue)
        error_style(issue.label)
        spacer
        error_style("#{issue.summary} in #{issue.in_test? ? issue.test_class : issue.class}")
        puts
        test_name_summary(issue)

        puts
        default_style("#{issue.location.test_file}:#{issue.location.test_definition_line} > #{issue.location.test_failure_line}")
        subtle_style("#{SPACER}#{issue.test_name}")
        puts

        puts "Backtrace:"
        lines = issue.backtrace.project
        lines.take(5).each do |line|
          default_style("  #{line.path.delete_prefix(Dir.pwd)}/#{line.file}:#{line.number} ")
          subtle_style("in `#{line.container}`")
          if line == issue.freshest_file && lines.size > 1
            default_style("#{SPACER}Most Recently Modified")
          end
          puts
        end
      end

      def skipped_formatter(issue)
        skipped_style(issue.label)
      end

      def failure_formatter(issue)
        failure_style(issue.label)
        spacer
        failure_style("#{issue.test_name}")
        subtle_style(" (#{issue.test_class} > #{issue.location.test_definition_line})")
        puts
        default_style("#{issue.location.test_file}:#{issue.location.test_failure_line}")
        puts
        lines = issue.relevant_lines_of_code
        lines.each_index do |i|
          line = "#{lines[i]}"
          i == 1 ? default_style(line) : subtle_style(line)
        end
        puts
        default_style(issue.summary)
        puts
      end

      def turtle_formatter(issue)
        turtle_style("Slow")
        spacer
        highlight_style("#{issue.time.round(3)}s")
        spacer
        test_name_summary(issue)
        puts
      end

      def test_name_summary(issue)
        default_style("#{issue.test_class} > #{issue.test_name}")
      end

      def spacer
        subtle_style(SPACER)
      end

      def error_style(value)
        text(:red, :bold) { value }
      end

      def failure_style(value)
        text(:red) { value }
      end

      def skipped_style(value)
        text(:yellow) { value }
      end

      def turtle_style(value)
        text(:yellow, :bold) { value }
      end

      def success_style(value)
        text(:green) { value }
      end

      def default_style(value)
        text(:default) { value }
      end

      def highlight_style(value)
        text(:white, :bold) { value }
      end

      def subtle_style(value)
        text(:white, :light) { value }
      end

      def compact_summary(results)
        error_count = results.errors.size
        failure_count = results.failures.size
        turtle_count = results.turtles.size
        skip_count = results.skips.size

        if error_count.positive?
          error_style(pluralize(error_count, 'error') + ' ')
          failure_style(pluralize(failure_count, 'failure') + ' ') if failure_count.positive?
          if turtle_count.positive?
          end
          if skip_count.positive? || turtle_count.positive?
            subtle_style(pluralize(skip_count, 'skip') + ' ') if skip_count.positive?
            subtle_style(pluralize(turtle_count, 'slow') + ' ') if turtle_count.positive?
            subtle_style("(Suppressing skips/slows to focus on failures.)")
          end
        elsif failure_count.positive?
          failure_style(pluralize(failure_count, 'failure') + ' ')
          if skip_count.positive? || turtle_count.positive?
            subtle_style(pluralize(skip_count, 'skip') + ' ') if skip_count.positive?
            subtle_style(pluralize(turtle_count, 'slow') + ' ') if turtle_count.positive?
            subtle_style("(Suppressing skips/slows to focus on failures.)")
          end
        elsif skip_count.positive? || turtle_count.positive?
          skipped_style(pluralize(skip_count, 'skip') + ' ')  if skip_count.positive?
          subtle_style(pluralize(turtle_count, 'slow') + ' ') if turtle_count.positive?
        end

        puts
        subtle_style(pluralize(results.test_count, 'test') + ' & ')
        subtle_style(pluralize(results.assertion_count, 'asserton'))

        puts
        highlight_style("#{results.total_time.round(2)}s ")
        subtle_style("#{results.tests_per_second} tests/s, #{results.assertions_per_second} assertions/s")
      end

      private

      def style_enabled?
        stream.tty?
      end

      def pluralize(count, singular)
        singular_style = "#{count} #{singular}"

        # Given the narrow scope, pluralization can be relatively naive here
        count > 1 ? "#{singular_style}s" : singular_style
      end

      def text(color = nil, weight = nil, &block)
        content = if style_enabled?
                    "#{style(color, weight)}#{block.call}#{RESET}"
                  else
                    block.call
                  end

        print content
      end

      def style(color, weight)
        weight = WEIGHTS.fetch(weight) { WEIGHTS[:default] }
        color = COLORS.fetch(color) { COLORS[:default] }

        "\e[#{weight};#{color}m"
      end
    end
  end
end
