# frozen_string_literal: true

if ENV['COVERAGE'] || ENV['CI']
  require 'simplecov'
  require 'simplecov_json_formatter'

  SimpleCov.print_error_status = false
  SimpleCov.start do
    enable_coverage :branch
    minimum_coverage 90
    minimum_coverage_by_file 80
    refuse_coverage_drop
  end

  formatters = [SimpleCov::Formatter::JSONFormatter]
  # Only use HTML formatter locally (has issues in CI with bundler deployment mode)
  formatters << SimpleCov::Formatter::HTMLFormatter unless ENV['CI']
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
