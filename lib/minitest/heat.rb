# frozen_string_literal: true

require_relative 'heat/configuration'
require_relative 'heat/backtrace'
require_relative 'heat/hit'
require_relative 'heat/issue'
require_relative 'heat/location'
require_relative 'heat/locations'
require_relative 'heat/map'
require_relative 'heat/output'
require_relative 'heat/results'
require_relative 'heat/source'
require_relative 'heat/timer'
require_relative 'heat/version'

module Minitest
  # Custom Minitest reporter focused on generating output designed around efficiently identifying
  # issues and potential solutions
  # - Colorize the Output
  # - What files had the most errors?
  # - Show the most impacted areas first.
  # - Show lowest-level (most nested code) frist.
  #
  # Pulls from existing reporters:
  #   https://github.com/seattlerb/minitest/blob/master/lib/minitest.rb#L554
  #
  # Lots of insight from:
  #   http://www.monkeyandcrow.com/blog/reading_ruby_minitest_plugin_system/
  #
  # And a good example available at:
  #   https://github.com/adamsanderson/minitest-snail
  #
  # Pulls from minitest-color as well:
  #   https://github.com/teoljungberg/minitest-color/blob/master/lib/minitest/color_plugin.rb
  module Heat
    class << self
      attr_writer :configuration
    end

    def self.configuration
      @configuration ||= Configuration.new
    end

    def self.reset
      @configuration = Configuration.new
    end

    def self.configure
      yield(configuration)
    end

    # Ruby labels text from outside Ruby source (paths, file contents, command output) with the
    # locale's encoding, which is US-ASCII or binary under `LC_ALL=C` or an unrecognized locale.
    # That text is overwhelmingly UTF-8, so unlabeled bytes are read as UTF-8 and text in any other
    # encoding is converted. Anything that isn't valid UTF-8 is replaced so that comparing,
    # displaying or serializing the text can't raise.
    #
    # @param text [String, nil] text from outside Ruby source
    #
    # @return [String, nil] valid UTF-8 text
    def self.utf8(text)
      return text unless text.is_a?(String)

      case text.encoding
      when Encoding::UTF_8, Encoding::US_ASCII, Encoding::BINARY
        String.new(text, encoding: Encoding::UTF_8).scrub
      else
        text.encode(Encoding::UTF_8, invalid: :replace, undef: :replace)
      end
    end

    # The directory the tests run from, which identifies project files
    #
    # @return [String] the current working directory as UTF-8
    def self.project_root = utf8(Dir.pwd)
  end
end
