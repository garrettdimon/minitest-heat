# 🔥 Minitest Heat 🔥
Minitest Heat helps you identify problems faster so you can more efficiently resolve test failures by generating a heat map that shows where failures are concentrated.

For a more detailed explanation of Minitest Heat with screenshots, [head over to the wiki for the full story](https://github.com/garrettdimon/minitest-heat/wiki).

Or for some additional insight about priorities and how it works, this [Twitter thread](https://twitter.com/garrettdimon/status/1432703746526560266) is a good read.

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
Minitest Heat doesn't currently offer a significant set of configuration options, but the thresholds for "Slow" and "Painfully Slow" tests can be adjusted. By default, it considers anything over 1.0s to be 'slow' and anything over 3.0s to be 'painfully slow'.

You can add a configuration block to your `test_helper.rb` file after the `require 'minitest/heat'` line.

For example:

```ruby
Minitest::Heat.configure do |config|
  config.slow_threshold = 0.01
  config.painfully_slow_threshold = 0.5
end
```

## Development
After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. For release instructions, see [RELEASING.md](RELEASING.md).

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
