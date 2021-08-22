# frozen_string_literal: true

module Minitest
  module Heat
    # Friendly API for printing nicely-formatted output to the console
    class Output
      Token = Struct.new(:style, :content) do
        STYLES = {
          error:   %i[bold red],
          failure: %i[default red],
          skipped: %i[bold yellow],
          success: %i[default green],
          turtle:  %i[bold yellow],
          bold:    %i[bold default],
          default: %i[default default],
          subtle:  %i[light default],
        }.freeze

        WEIGHTS = {
          default: 0,
          bold: 1,
          light: 2
        }.freeze

        COLORS = {
          red: 31,
          green: 32,
          yellow: 33,
          gray: 37,
          default: 39,
          white: 97
        }.freeze

        def to_s
          "\e[#{weight};#{color}m#{content}#{reset}"
        end

        private

        def weight
          WEIGHTS.fetch(style_components[0])
        end

        def color
          COLORS.fetch(style_components[1])
        end

        def reset
          "\e[0m"
        end

        def style_components
          STYLES[style]
        end
      end

      FORMATTERS = {
        error: [
          [ %i[error label], %i[subtle spacer], %i[error test_name], %i[subtle arrow], %i[error test_class] ],
          [ %i[default summary], %i[subtle spacer], %i[subtle class], ],
          [ %i[default backtrace_summary] ],
        ],
        failure: [
          [ %i[failure label], %i[subtle spacer], %i[failure test_name], %i[subtle arrow], %i[failure test_class] ],
          [ %i[default summary], %i[subtle spacer], %i[subtle class], ],
          [ %i[default source_summary], ],
        ],
        skipped: [
          [ %i[skipped label] ],
        ],
        turtle: [
          [ %i[turtle label], %i[subtle spacer], %i[default test_name], %i[subtle arrow], %i[subtle test_class],],
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
        newline
      end

      def heat_map(map)
        text(:default, "Hot Spots:\n")
        map.files.each do |file|
          filename = file[0]
          values = map.hits[filename]

          text(:bold, "#{filename} ")
          text(:error, 'E' * values[:error].size) if values[:error].any?
          text(:failure, 'F' * values[:failure].size) if values[:failure].any?
          newline
        end
        puts
      end

      def compact_summary(results)
        error_count = results.errors.size
        failure_count = results.failures.size
        turtle_count = results.turtles.size
        skip_count = results.skips.size

        if error_count.positive?
          text(:error, pluralize(error_count, 'error') + ' ')
          text(:failure, pluralize(failure_count, 'failure') + ' ') if failure_count.positive?
          if turtle_count.positive?
          end
          if skip_count.positive? || turtle_count.positive?
            text(:subtle, pluralize(skip_count, 'skip') + ' ') if skip_count.positive?
            text(:subtle, pluralize(turtle_count, 'slow') + ' ') if turtle_count.positive?
            text(:subtle, "(Suppressing skips/slows to focus on failures.)")
          end
        elsif failure_count.positive?
          text(:failure, pluralize(failure_count, 'failure') + ' ')
          if skip_count.positive? || turtle_count.positive?
            text(:subtle, pluralize(skip_count, 'skip') + ' ') if skip_count.positive?
            text(:subtle, pluralize(turtle_count, 'slow') + ' ') if turtle_count.positive?
            text(:subtle, "(Suppressing skips/slows to focus on failures.)")
          end
        elsif skip_count.positive? || turtle_count.positive?
          text(:skipped, pluralize(skip_count, 'skip') + ' ')  if skip_count.positive?
          text(:subtle, pluralize(turtle_count, 'slow') + ' ') if turtle_count.positive?
        end

        puts
        text(:subtle, pluralize(results.test_count, 'test') + ' & ')
        text(:subtle, pluralize(results.assertion_count, 'assertion'))

        puts
        text(:bold, "#{results.total_time.round(2)}s ")
        text(:subtle, "#{results.tests_per_second} tests/s, #{results.assertions_per_second} assertions/s")

        puts
        puts
      end

      private

      def test_name_summary(issue)
        text(:default, "#{issue.test_class} > #{issue.test_name}")
      end

      def backtrace_summary(issue)
        lines = issue.backtrace.project

        lines.take(5).each do |line|
          text(:subtle, "#{line.path.delete_prefix(Dir.pwd)}/")
          text(:default, "#{line.file}:#{line.number} ")
          if line == issue.freshest_file && lines.size > 1
            text(:subtle, "< Most Recently Modified")
          end
          newline

          if line == lines.first || line == issue.freshest_file && lines.size > 1
            # filename = "#{line.path.delete_prefix(Dir.pwd)}/#{line.file}"
            # source = Minitest::Heat::Source.new(filename, line_number: line.number, max_line_count: 3)
            # show_source(source, indentation: 2)
          end
        end
      end

      def source_summary(issue)
        filename = issue.location.source_file
        line_number = issue.location.source_failure_line

        source = Minitest::Heat::Source.new(filename, line_number: line_number, max_line_count: 5)
        show_source(source, highlight_line: true)
      end

      def show_source(source, indentation: 0, highlight_line: false)
        max_line_number_length = source.line_numbers.map(&:to_s).map(&:length).max
        source.lines.each_index do |i|
          line_number = source.line_numbers[i]
          line = source.lines[i]

          style = line == source.line && highlight_line ? :default : :subtle
          text(style, "#{' ' * indentation}#{line_number.to_s.rjust(max_line_number_length)}: #{line}")
          puts
        end
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
        formatted_content = style_enabled? ? Token.new(style, content).to_s : content

        print formatted_content
      end
    end
  end
end
