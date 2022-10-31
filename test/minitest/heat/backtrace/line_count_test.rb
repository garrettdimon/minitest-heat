# frozen_string_literal: true

require 'test_helper'

class Minitest::Heat::Backtrace::LineCountTest < Minitest::Test
  def setup
    @test_location = ["#{Dir.pwd}/test/minitest/heat_test.rb", 23]
    @raw_backtrace = [
      "#{Dir.pwd}/lib/minitest/heat.rb:29:in `method_name'",
      "#{Dir.pwd}/test/minitest/heat_test.rb:27:in `other_method_name'",
      "#{Gem.dir}/gems/minitest-5.14.4/lib/minitest/test.rb:98:in `block (3 levels) in run'",
      "#{Gem.dir}/gems/minitest-5.14.4/lib/minitest/test.rb:195:in `capture_exceptions'",
      "#{Gem.dir}/gems/minitest-5.14.4/lib/minitest/test.rb:95:in `block (2 levels) in run'",
      "#{Dir.pwd}/lib/minitest/heat.rb:29:in `method_name'",
      "#{Dir.pwd}/test/minitest/heat_test.rb:27:in `other_method_name'",
      "#{Gem.dir}/gems/minitest-5.14.4/lib/minitest/test.rb:98:in `block (3 levels) in run'",
      "#{Gem.dir}/gems/minitest-5.14.4/lib/minitest/test.rb:195:in `capture_exceptions'",
      "#{Gem.dir}/gems/minitest-5.14.4/lib/minitest/test.rb:95:in `block (2 levels) in run'",
      "/file.rb:123: in `block'",
      "/file.rb:123: in `block'",
      "/file.rb:123: in `block'"
    ]

    @locations = Minitest::Heat::Locations.new(@test_location, @raw_backtrace)
    @line_count = ::Minitest::Heat::Backtrace::LineCount.new(@locations.backtrace.locations)
  end

  def test_earliest_project_location
    assert_equal 6, @line_count.earliest_project_location
  end

  def test_max_location
    assert_equal 12, @line_count.max_location
  end

  def test_uses_earliest_project_location_if_present
    assert_equal 6, @line_count.limit
  end

  def test_uses_default_line_count_if_lots_of_non_project_locations
    @raw_backtrace = []
    25.times do
      @raw_backtrace << "/file.rb:123: in `block'"
    end

    @locations = Minitest::Heat::Locations.new(@test_location, @raw_backtrace)
    @line_count = ::Minitest::Heat::Backtrace::LineCount.new(@locations.backtrace.locations)

    assert_equal 20, @line_count.limit
  end

  def test_uses_max_if_no_project_files_and_not_enough_for_default
    @raw_backtrace = []
    5.times do
      @raw_backtrace << "/file.rb:123: in `block'"
    end

    @locations = Minitest::Heat::Locations.new(@test_location, @raw_backtrace)
    @line_count = ::Minitest::Heat::Backtrace::LineCount.new(@locations.backtrace.locations)

    assert_equal @line_count.max_location, @line_count.limit
  end
end
