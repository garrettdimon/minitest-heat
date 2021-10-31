# frozen_string_literal: true

require_relative 'heat_reporter'

module Minitest # rubocop:disable Style/Documentation
  def self.plugin_heat_init(options)
    io = options.fetch(:io, $stdout)

    self.reporter.reporters.reject! do |reporter|
      # Minitest Heat acts as a unified Progress *and* Summary reporter. Using other reporters of
      # those types in conjunction with it creates some overly-verbose output
      reporter.is_a?(ProgressReporter) || reporter.is_a?(SummaryReporter)
    end

    # Hook up Reviewer
    self.reporter.reporters << HeatReporter.new(io, options)
  end
end
