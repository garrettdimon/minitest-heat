# Minitest::Heat
**Important:** As of September 13, 2021, Minitest::Heat is an early work-in-progress. It's usable, but it can still ocasionally be buggy as it takes shape.

Minitest::Heat aims to surface context around test failures to help you more efficiently identify and prioritize fixing failed tests to help save time.

For some early insight about priorities and how it works, this [Twitter thread](https://twitter.com/garrettdimon/status/1432703746526560266) is currently the best place to start.

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

## Usage

**Important:** In its current state, `Minitest::Heat` replaces any other reporter plugins you may have. Long-term, it should play nicer with other reporters, but during the initial heavy development cycle, it's been easier to have a high confidence that other reporters aren't the source of unexpected behavior.

Otherwise, once it's bundled and added to your `test_helper`, it shold "just work" whenever you run your test suite.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/minitest-heat. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/minitest-heat/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Minitest::Heat project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/minitest-heat/blob/master/CODE_OF_CONDUCT.md).
