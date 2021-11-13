# frozen_string_literal: true

require 'test_helper'

class Minitest::Heat::Output::BacktraceTest < Minitest::Test
  def setup
    @test_location = ["#{Dir.pwd}/test/minitest/heat_test.rb", 23]
    @raw_backtrace = [
      "#{Dir.pwd}/lib/minitest/heat.rb:29:in `method_name'",
      "#{Dir.pwd}/test/minitest/heat_test.rb:27:in `other_method_name'",
      "#{Gem.dir}/gems/minitest-5.14.4/lib/minitest/test.rb:98:in `block (3 levels) in run'",
      "#{Gem.dir}/gems/minitest-5.14.4/lib/minitest/test.rb:195:in `capture_exceptions'",
      "#{Gem.dir}/gems/minitest-5.14.4/lib/minitest/test.rb:95:in `block (2 levels) in run'"
    ]

    @location = Minitest::Heat::Locations.new(@test_location, @raw_backtrace)

    @backtrace = ::Minitest::Heat::Output::Backtrace.new(@location)
  end
end
