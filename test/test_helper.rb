# frozen_string_literal: true

if ENV['COVERAGE']
  require 'simplecov'

  SimpleCov.print_error_status = false
  SimpleCov.start do
    enable_coverage :branch
    minimum_coverage 100
    minimum_coverage_by_file 100
    refuse_coverage_drop
  end

  if ENV['CI'] == 'true'
    require 'codecov'
    SimpleCov.formatter = SimpleCov::Formatter::Codecov
  else
    # With the JSON formatter, Reviewwer can look at the results and show guidance without needing
    # to open the HTML view
    formatters = [
      SimpleCov::Formatter::SimpleFormatter,
      SimpleCov::Formatter::HTMLFormatter
    ]
    SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new(formatters)
  end
end

require 'pry'

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'awesome_print'
require 'minitest/heat'
require 'minitest/autorun'
