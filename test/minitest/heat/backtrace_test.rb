# frozen_string_literal: true

require 'test_helper'

class Minitest::Heat::BacktraceTest < Minitest::Test
  def setup
    project_dir = Dir.pwd
    gem_dir = Gem.dir

    @source_code_line = "#{project_dir}/lib/minitest/heat.rb:29:in `method_name'"
    @test_line = "#{project_dir}/test/minitest/heat_test.rb:27:in `other_method_name'"

    @raw_backtrace = [
      @source_code_line,
      @test_line,
      "#{gem_dir}/gems/minitest-5.14.4/lib/minitest/test.rb:98:in `block (3 levels) in run'",
      "#{gem_dir}/gems/minitest-5.14.4/lib/minitest/test.rb:195:in `capture_exceptions'",
      "#{gem_dir}/gems/minitest-5.14.4/lib/minitest/test.rb:95:in `block (2 levels) in run'"
    ]
    @key_file = @raw_backtrace.first.split(':').first

    @backtrace = Minitest::Heat::Backtrace.new(@raw_backtrace)
  end

  def test_fails_gracefully_when_it_cannot_read_a_file
    @raw_backtrace = ["/file/does/not/exist.rb:5:in `capture_exceptions'"]
    @backtrace = Minitest::Heat::Backtrace.new(@raw_backtrace)

    refute_nil @backtrace.locations.first
  end

  def test_keeping_only_project_locations
    refute_equal @backtrace.locations, @backtrace.project_locations
    assert_equal @backtrace.locations.first, @backtrace.project_locations.first
    refute_equal @backtrace.locations.last, @backtrace.project_locations.last
  end

  def test_keeping_only_source_code_locations
    refute_equal @backtrace.locations, @backtrace.source_code_locations
    assert_equal @backtrace.locations.first, @backtrace.source_code_locations.first
    refute_equal @backtrace.locations.last, @backtrace.source_code_locations.last
  end

  def test_sorting_locations_by_modified_time
    # Ensure the first file was recently updated
    FileUtils.touch(@backtrace.locations.first.pathname)
    sorted_locations = @backtrace.project_locations.sort_by(&:mtime).reverse

    assert sorted_locations.first.mtime >= sorted_locations.last.mtime, "#{sorted_locations.first.mtime} was not greater than #{sorted_locations.last.mtime}"
    assert_equal sorted_locations, @backtrace.recently_modified_locations
  end

  def test_keeping_only_test_locations
    assert_equal 1, @backtrace.test_locations.size
    refute_equal @backtrace.project_locations, @backtrace.test_locations
  end
end
