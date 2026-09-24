# frozen_string_literal: true

require_relative '../support/heat_activation'

class RecordingErrorTest < Minitest::Test
  class UnprintableError < StandardError
    def message
      raise 'exception message formatting failed'
    end
  end

  # Ensure the successful result is recorded after the reporting error.
  def self.test_order = :alpha
  def self.run_order = :alpha

  def test_a_unprintable_error
    raise UnprintableError
  end

  def test_b_passing
    assert true
  end
end
