## [Unreleased]

## [1.3.0] - 2026-01-29

### Added
- JSON output mode via `--heat-json` flag for CI and tooling integration
- Expanded README documentation covering issue priority order and heat map scanning
- GitHub Actions release automation with trusted publishing to RubyGems
- Pre-release validation rake tasks (`release:preflight`, `release:check`, `release:audit`, `release:dry_run`)
- Comprehensive release documentation (RELEASING.md)

### Fixed
- Muted text now readable on light terminal backgrounds (uses terminal default color instead of gray)
- Defensive error handling throughout to prevent exception messages from bubbling up
- Off-by-one error in backtrace line_count calculation
- Handle nil values safely in source.rb, line_parser.rb, backtrace.rb, issue.rb, and output classes
- Bare rescue clause in output.rb now catches specific exceptions

### Changed
- Significantly improved test coverage for Output classes and Results
- Updated CI to test on Ruby 3.0, 3.1, 3.2, 3.3, 3.4, and 4.0 on Ubuntu
- Made development dependencies (debug, awesome_print) optional for easier setup
- Removed deprecated codecov gem reference
- Removed outdated Travis CI configuration (GitHub Actions is now the primary CI)
- Updated GitHub Actions to use checkout@v4
- Updated Gemfile.lock so CI uses the latest patched dependency versions

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

