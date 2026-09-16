# frozen_string_literal: true

require_relative '../support/heat_activation'
require_relative 'exit_status_source'

# Run only in a subprocess, with one scenario selected by --name.
class ExitStatusTest < Minitest::Test
  def test_passing
    assert true
  end

  def test_broken
    raise 'deterministic exception inside a test'
  end

  def test_failure
    flunk 'deterministic assertion failure'
  end

  def test_error
    ExitStatusSource.raise_error
  end

  def test_skipped
    skip 'deterministic skip'
  end
end
