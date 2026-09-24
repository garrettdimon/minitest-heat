# frozen_string_literal: true

require 'test_helper'
require 'json'
require 'open3'
require 'rbconfig'
require 'tmpdir'

# Runs a small suite in a child process under `LC_ALL=C` from a project directory whose name
# contains non-ASCII characters. Ruby then labels the working directory, backtrace paths and
# text read from files with non-UTF-8 encodings, which a single process can't simulate.
class Minitest::HeatNonUtf8LocaleTest < Minitest::Test
  LIB = File.expand_path('../../lib', __dir__)

  SOURCE = <<~RUBY
    class Thing
      def call = raise(ArgumentError, 'naïve failure')
    end
  RUBY

  TEST = <<~RUBY
    require 'minitest/autorun'
    Minitest.load :heat if Minitest::VERSION.to_i >= 6
    require_relative 'thing'

    class EncodingScenarioTest < Minitest::Test
      def test_error_from_source = Thing.new.call

      def test_failure_with_message_read_from_a_file
        flunk "file contained \#{File.read(File.join(__dir__, 'data.txt')).chomp}"
      end

      def test_plain_failure = assert_equal(1, 2)
    end
  RUBY

  def test_json_output_reports_every_issue
    stdout, stderr, status = run_suite('--heat-json')
    issues = JSON.parse(stdout).fetch('issues')

    assert_equal 1, status.exitstatus, stderr
    refute_includes stderr, 'Sorry'
    assert_equal %w[error failure failure], issues.map { |issue| issue.fetch('type') }.sort
    assert(issues.any? { |issue| issue.fetch('message').include?('file contained café') }, stdout)
    assert(issues.any? { |issue| issue.fetch('message').start_with?('ArgumentError: naïve failure') }, stdout)
  end

  def test_json_output_reports_locations_relative_to_the_project
    stdout, = run_suite('--heat-json')
    files = JSON.parse(stdout).fetch('issues').map { |issue| issue.fetch('failure_location').fetch('file') }

    assert_equal %w[encoding_scenario_test.rb encoding_scenario_test.rb thing.rb], files.sort, stdout
  end

  def test_text_output_displays_every_issue
    stdout, stderr, status = run_suite

    assert_equal 1, status.exitstatus, stderr
    refute_includes stdout + stderr, 'Sorry'
    assert_includes stdout, 'file contained café'
    assert_includes stdout, 'ArgumentError: naïve failure'
    assert_includes stdout, 'Expected: 1'
  end

  private

  def run_suite(*options)
    Dir.mktmpdir do |tmp|
      project = File.join(tmp, 'café')
      Dir.mkdir(project)
      File.write(File.join(project, 'thing.rb'), SOURCE)
      File.write(File.join(project, 'data.txt'), "café\n")
      File.write(File.join(project, 'encoding_scenario_test.rb'), TEST)

      stdout, stderr, status = Open3.capture3(
        { 'LC_ALL' => 'C', 'LANG' => 'C', 'MT_NO_PLUGINS' => nil },
        RbConfig.ruby, "-I#{LIB}", 'encoding_scenario_test.rb', *options,
        chdir: project, binmode: true
      )
      [stdout.force_encoding(Encoding::UTF_8), stderr.force_encoding(Encoding::UTF_8), status]
    end
  end
end
