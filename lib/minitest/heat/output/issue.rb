# frozen_string_literal: true

module Minitest
  module Heat
    class Output
      class Issue
        attr_accessor :issue

        def initialize(issue)
          @issue = issue
        end

        def tokens
        end
      end
    end
  end
end
