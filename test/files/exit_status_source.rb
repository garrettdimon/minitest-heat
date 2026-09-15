# frozen_string_literal: true

module ExitStatusSource
  def self.raise_error
    raise 'deterministic exception outside a test'
  end
end
