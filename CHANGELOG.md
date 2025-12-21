## [Unreleased]

### Breaking Changes
- Minimum Ruby version is now 3.1 (Ruby 2.7 reached EOL in March 2023)

### Improvements
- Significantly improved test coverage for Output classes and Results
- Updated CI to test on Ruby 3.0, 3.1, 3.2, and 3.3 on both Ubuntu and macOS
- Fixed bare rescue clause in output.rb to catch specific exceptions
- Made development dependencies (debug, awesome_print) optional for easier setup
- Removed deprecated codecov gem reference
- Removed outdated Travis CI configuration (GitHub Actions is now the primary CI)
- Updated GitHub Actions to use checkout@v4
- Removed Gemfile.lock to allow CI to use latest patched dependency versions

## [1.2.0] - 2022-10-31

Mainly some improvements to make test failures more resilient and improve the formatting when there are issues.

- Don't consider binstubs project files when colorizing the stacktrace.
- Switch debugging from Pry to debug
- Ensure overly-long exception messages are truncated to reduce excessive scrolling
- Make backtrace display smarter about how many lines to display
- Fix bug that was incorrectly deleting the bin directory
- Prepare for better handling of "stack level too deep" traces

## [1.1.0] - 2021-12-09

The biggest update is that the slow thresholds are now configurable.

- Configurable Thresholds
- Fixed a bug where `vendor/bundle` gem files were considered project source code files
- Set up [GitHub Actions](https://github.com/garrettdimon/minitest-heat/actions) to ensure tests are run on Ubuntu latest and macOs for the [latest Ruby versions](https://github.com/garrettdimon/minitest-heat/blob/main/.github/workflows/main.yml)
- Fixed some tests that were accidentally left path-dependent and couldn't pass on other machines

## [1.0.0] - 2021-12-01

Initial release.

