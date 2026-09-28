# Agent guidance

Minitest Heat is a Ruby gem that replaces Minitest's default output with a heat map showing
where failures concentrate, so the most impactful problems come first. See the
[README](README.md) for usage and [RELEASING.md](RELEASING.md) for releases.

## Commands

```bash
bin/setup                                            # install dependencies
bundle exec rvw tests -f test/minitest/heat/issue_test.rb  # focused tests for changed code
bundle exec rvw staged                               # review gate before committing
bundle exec rake test                                # full suite
bundle exec rubocop                                  # lint
bin/console                                          # interactive console
bundle exec rake test TESTOPTS="--heat-json"         # JSON output for tooling
```

To see every failure type the reporter renders, force the contrived failures in
`test/minitest/contrived_*.rb`: `IMPLODE=true bundle exec rake test`, or one type at a time
with `FORCE_EXCEPTIONS`, `FORCE_FAILURES`, `FORCE_SKIPS` or `FORCE_SLOWS`.

## Architecture

- `lib/minitest/heat_plugin.rb` registers the reporter through Minitest's plugin system,
  replacing the default progress and summary reporters, and adds `--heat-json`.
- `lib/minitest/heat_reporter.rb` (`Minitest::HeatReporter`) coordinates timing, results
  and output.
- `lib/minitest/heat/` holds the domain models: `Issue` classifies a Minitest result
  (`:error`, `:broken` for errors in test files, `:failure`, `:skipped`, `:painful`,
  `:slow`, `:success`); `Results` aggregates issues; `Map` and `Hit` weight file
  locations by severity; `Locations`, `Location` and `Backtrace` separate project code
  from gems; `Timer` and `Source` supply timing and source context.
- `lib/minitest/heat/output/` renders the terminal display: markers, issues, source
  code, backtraces, the map and the summary.

Issues are shown in priority order: errors, broken tests and failures; skips only when
there are none of those; slow tests only when there are no skips either.

Configuration defaults live in `lib/minitest/heat/configuration.rb`: `slow_threshold`
1.0 seconds, `painfully_slow_threshold` 3.0 seconds, and `inherently_slow_paths`, a list
of path prefixes excluded from slow reporting.

## Testing

Tests in `test/minitest/heat/` mirror `lib/`. `test/test_helper.rb` lowers the slow
thresholds to 0.05 and 0.1 seconds so slow detection triggers during development.
Several tests assert paths built from `__FILE__`; run them from the repository root.
