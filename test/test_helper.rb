# frozen_string_literal: true

if ENV['COVERAGE'] || ENV['CI']
  require 'simplecov'
  require 'simplecov_json_formatter'

  SimpleCov.print_error_status = false
  SimpleCov.start do
    enable_coverage :branch
    minimum_coverage 90
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

require 'minitest/heat'
require_relative 'support/heat_activation'

require_relative 'support/issue_helpers'

Minitest::Heat.configure do |config|
  config.slow_threshold = 0.05
  config.painfully_slow_threshold = 0.1
end

class Minitest::Test
  include IssueHelpers

  # Simulates a non-UTF-8 locale (e.g. LC_ALL=C) regardless of the developer's own locale.
  # Ruby warns when this changes, so warnings are silenced while swapping.
  def with_default_external(encoding)
    original = Encoding.default_external
    swap_default_external(encoding)
    yield
  ensure
    swap_default_external(original)
  end

  def swap_default_external(encoding)
    verbose = $VERBOSE
    $VERBOSE = nil
    Encoding.default_external = encoding
  ensure
    $VERBOSE = verbose
  end
end
