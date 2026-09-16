# frozen_string_literal: true

require 'test_helper'
require 'json'
require 'open3'
require 'rbconfig'

class Minitest::HeatPluginTest < Minitest::Test
  def test_repeated_activation_emits_one_report
    stdout, stderr, status = run_script(<<~RUBY, '--heat-json')
      if Minitest::VERSION.to_i >= 6
        2.times { Minitest.load :heat }
      else
        require 'minitest/heat_plugin'
        Minitest.extensions.concat(%w[heat heat])
      end
    RUBY

    assert status.success?, stderr
    result = JSON.parse(stdout)
    assert_equal 'passed', result.fetch('status')
    assert_equal 1, result.fetch('statistics').fetch('total')
  end

  def test_activation_loads_the_checkout_plugin
    activation = Minitest::VERSION.to_i >= 6 ? 'Minitest.load :heat' : ''
    stdout, stderr, status = run_script(<<~RUBY, '--heat-json')
      #{activation}
      Minitest.after_run do
        expected = File.expand_path('lib/minitest/heat_plugin.rb')
        actual = Minitest.method(:plugin_heat_init).source_location.first
        abort "Wrong Heat plugin: \#{actual}" unless File.expand_path(actual) == expected
        abort 'Wrong Minitest version' unless Gem.loaded_specs.fetch('minitest').version.to_s == #{Gem.loaded_specs.fetch('minitest').version.to_s.inspect}
      end
    RUBY

    assert status.success?, stderr
    assert_equal 1, JSON.parse(stdout).fetch('statistics').fetch('total')
  end

  def test_minitest_six_requires_opt_in
    skip 'Minitest 5 automatically discovers plugins' if Minitest::VERSION.to_i < 6

    stdout, stderr, status = run_script('', '--heat-json')
    refute status.success?
    assert_includes "#{stdout}#{stderr}", 'invalid option: --heat-json'
  end

  private

  def run_script(activation, *)
    script = <<~RUBY
      require 'minitest/autorun'
      #{activation}
      class PluginProbe < Minitest::Test
        def test_pass
          assert true
        end
      end
    RUBY
    Open3.capture3(
      { 'MT_NO_PLUGINS' => nil }, RbConfig.ruby, '-Ilib', '-e', script, '--', *,
      chdir: File.expand_path('../..', __dir__)
    )
  end
end
