# frozen_string_literal: true

require_relative 'heat_reporter'

module Minitest
  def self.plugin_heat_options(opts, _options)
    opts.on '--show-fast', 'Show failures as they happen instead of waiting for the entire suite.' do
      # Heat.show_fast!
    end

    # TODO: options.
    # 1. Fail Fast
    # 2. Don't worry about skips.
    # 3. Skip coverage.
  end

  def self.plugin_heat_init(options)
    io = options[:io]

    # Clean out the existing reporters.
    reporter.reporters = []

    # Use Reviewer as the sole reporter.
    reporter << HeatReporter.new(io, options)
  end
end
