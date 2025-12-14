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

  # With the JSON formatter, code review tools can analyze results without opening the HTML view
  formatters = [
    SimpleCov::Formatter::SimpleFormatter,
    SimpleCov::Formatter::HTMLFormatter
  ]
  SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new(formatters)
end

begin
  require 'debug'
rescue LoadError
  # debug gem is optional for development
end

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

begin
  require 'awesome_print'
rescue LoadError
  # awesome_print gem is optional for development
end
require 'minitest/heat'
require 'minitest/autorun'

Minitest::Heat.configure do |config|
  config.slow_threshold = 0.0005
  config.painfully_slow_threshold = 0.01
end
