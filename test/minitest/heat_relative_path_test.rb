# frozen_string_literal: true

require 'test_helper'
require 'json'
require 'open3'
require 'rbconfig'

class Minitest::HeatRelativePathTest < Minitest::Test
  def test_test_exception_has_same_classification_and_location_for_relative_path
    assert_equivalent_paths('broken', 'broken', 'test/files/test_exit_status.rb', 13)
  end

  def test_source_exception_has_same_classification_and_location_for_relative_path
    assert_equivalent_paths('error', 'error', 'test/files/exit_status_source.rb', 5)
  end

  private

  def assert_equivalent_paths(scenario, type, failure_file, failure_line)
    root = File.expand_path('../..', __dir__)
    fixture = 'test/files/test_exit_status.rb'
    [File.join(root, fixture), fixture].each do |path|
      stdout, stderr, status = Open3.capture3(
        { 'MT_NO_PLUGINS' => nil }, RbConfig.ruby, '-Ilib', path,
        '--name', "test_#{scenario}", '--heat-json', chdir: root
      )
      refute_empty stdout, stderr
      result = JSON.parse(stdout)
      issue = result.fetch('issues').fetch(0)

      assert_equal 1, status.exitstatus, stderr
      assert_equal type, issue.fetch('type'), stdout
      assert_equal failure_file, issue.fetch('failure_location').fetch('file'), stdout
      assert_equal failure_line, issue.fetch('failure_location').fetch('line'), stdout
    end
  end
end
