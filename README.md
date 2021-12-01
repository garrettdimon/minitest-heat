# 🔥 Minitest::Heat 🔥
Minitest::Heat helps you identify problems faster so you can more efficiently resolve test failures. It does this through a few different methods.

It collects failures and inspects backtraces to identify patterns and provide a heat map summary of the files and line numbers that most frequently appear to be the causes of issues.

![Example Heat Map Displayed by Minitest Heat](https://raw.githubusercontent.com/garrettdimon/minitest-heat/main/examples/map.png)

It suppresses less critical issues like skips or slows when there are legitimate failures. It won't display information about slow tests unless all tests are passing (meaning no errors, failures, or skips)

It presents failures differently depending on the context of failure. For instance, it treats exceptions differently based on whether they arose directly from a test or from source code. It also treats extremely slow tests differently from moderately slow tests.

Markers get some nuance so that slow tests receive different markers than standard passing tests, and exception-triggered failures get different markers for source-code triggered exceptions (E) and test-triggered exceptions ('B' for 'Broken Test').

![Example Markers Displayed by Minitest Heat](https://raw.githubusercontent.com/garrettdimon/minitest-heat/main/examples/markers.png)

It also formats the failure details and backtraces to make them more scannable by emphasizing the project-relates lines from the backtrace.

It intelligently recognizes when an exception was raised from a test defintion vs. when an exception is genuinely triggered from the source code in order to help focus on fixing deeper exceptions first.

![Example Exceptions Displayed by Minitest Heat](https://raw.githubusercontent.com/garrettdimon/minitest-heat/main/examples/exceptions.png)

Failures are displayed ina  fairly predictable manner but formatted to show the source code from the test so you can see the assertion that failed in addition to the summary of values that didn't satisfy the assertion.

![Example Failures Displayed by Minitest Heat](https://raw.githubusercontent.com/garrettdimon/minitest-heat/main/examples/failures.png)

Skipped tests are displayed in a simple manner as well so that it's easy to see the source of the skipped test as well as the reason it was skipped.

![Example Skips Displayed by Minitest Heat](https://raw.githubusercontent.com/garrettdimon/minitest-heat/main/examples/skips.png)

Slow tests get slightly more informative labels to indicate that they did pass, but they could use performance improvements. Tests that are particularly slow are called out with a little more emphasis so it's easier to focus on really slow tests first as they frequently represent the most potential for performance gains.

![Example Slows Displayed by Minitest Heat](https://raw.githubusercontent.com/garrettdimon/minitest-heat/main/examples/slows.png)

It also always displays the most significant issues at the bottom of the list in order to reduce the need to scroll up through the test failures. As you fix issues, the list becomes shorter, and the less significant issues will make there way to the bottom and be visible without scrolling.

For some additional insight about priorities and how it works, this [Twitter thread](https://twitter.com/garrettdimon/status/1432703746526560266) is currently the best place to start.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'minitest-heat'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install minitest-heat

And depending on your usage, you may need to require Minitest Heat in your test suite:

```ruby
require 'minitest/heat'
```

## Configuration
Minitest Heat doesn't currently offer a significant set of configuration options, but it will eventually support customizing the thresholds for "Slow" and "Painfully Slow". By default, it considers anything over 1.0s to be 'slow' and anything over 3.0s to be 'painfully slow'.

## Development
After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Forcing Test Failures
In order to easily see how Minitest Heat handles different combinations of different types of failures, the following environment variables can be used to force failures.

```bash
IMPLODE=true           # Every possible type of failure, skip, and slow is generated
FORCE_EXCEPTIONS=true  # Only exception-triggered failures
FORCE_FAILURES=true    # Only standard assertion failures
FORCE_SKIPS=true       # No errors, just the skipped tests
FORCE_SLOWS=true       # No errors or skipped tests, just slow tests
```

So to see the full context of a test suite, `IMPLODE=true bundle exec rake` will work its magic.

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/garrettdimon/minitest-heat. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/minitest-heat/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct
Everyone interacting in the Minitest::Heat project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/minitest-heat/blob/master/CODE_OF_CONDUCT.md).
