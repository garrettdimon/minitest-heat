# Releasing Minitest Heat

## Quick Reference

```bash
# 1. Update version and changelog
# 2. Commit and push
git add -A && git commit -m "Release vX.Y.Z" && git push

# 3. Tag and push
git tag vX.Y.Z && git push origin vX.Y.Z

# Done - automation handles the rest
```

## How It Works

Releases are fully automated via GitHub Actions:

1. **Branch protection** requires CI to pass before merging to `main`
2. When you push a version tag, the release workflow:
   - Validates the tag points to a commit on `main` (ensures CI passed)
   - Builds and publishes the gem to RubyGems
   - Creates a GitHub Release with changelog excerpt

No redundant test runs. If it's on `main`, it already passed CI.

## Release Steps

### 1. Update Version

Edit `lib/minitest/heat/version.rb`:

```ruby
VERSION = 'X.Y.Z'
```

### 2. Update CHANGELOG

Move items from `[Unreleased]` to a new version section:

```markdown
## [Unreleased]

## [X.Y.Z] - YYYY-MM-DD

### Added
- New feature description

### Fixed
- Bug fix description
```

### 3. Commit, Tag, Push

```bash
git add lib/minitest/heat/version.rb CHANGELOG.md
git commit -m "Release vX.Y.Z"
git push origin main
git tag vX.Y.Z
git push origin vX.Y.Z
```

### 4. Verify

- Watch the [Actions tab](https://github.com/garrettdimon/minitest-heat/actions) for workflow completion
- Check [RubyGems](https://rubygems.org/gems/minitest-heat) for the new version
- Check [GitHub Releases](https://github.com/garrettdimon/minitest-heat/releases) for the release page

## Versioning Policy

Follow [Semantic Versioning](https://semver.org/):

- **MAJOR** (x.0.0): Breaking changes to public API or configuration
- **MINOR** (0.x.0): New features, deprecations
- **PATCH** (0.0.x): Bug fixes, documentation

### What's a Breaking Change?

- Removing or renaming public classes/methods
- Changing method signatures incompatibly
- Changing default configuration behavior
- Dropping Ruby version support

## Local Tools

### Full Preflight Check

Run all checks before pushing:

```bash
bundle exec rake release:preflight
```

This runs tests, security audit, and release validation in sequence.

### Individual Tasks

| Task | Purpose |
|------|---------|
| `rake release:preflight` | Run all checks (test, audit, check) |
| `rake release:check` | Validate version format, changelog entry, git state |
| `rake release:audit` | Check for vulnerable dependencies |
| `rake release:dry_run` | Build gem locally, show contents and size |
| `rake test` | Run test suite |

### Preview a Release

Before tagging, preview what the gem will contain:

```bash
bundle exec rake release:dry_run
```

This builds the gem, displays its contents and size, then cleans up.

## One-Time Setup

### RubyGems Trusted Publishing

1. Go to [rubygems.org/profile/oidc/pending_trusted_publishers](https://rubygems.org/profile/oidc/pending_trusted_publishers)
2. Add trusted publisher:
   - **Gem name:** `minitest-heat`
   - **Repository owner:** `garrettdimon`
   - **Repository name:** `minitest-heat`
   - **Workflow filename:** `release.yml`
   - **Environment:** `rubygems`

### GitHub Environment

1. Go to repository Settings > Environments
2. Create environment named `rubygems`
3. (Optional) Add required reviewers for extra safety

### Repository Ruleset

1. Go to repository Settings > Rules > Rulesets
2. Edit the `main` ruleset (or create one targeting the default branch)
3. Enable "Require status checks to pass" with these checks:
   - `Security`
   - `Test (Ruby 3.0)`
   - `Test (Ruby 3.1)`
   - `Test (Ruby 3.2)`
   - `Test (Ruby 3.3)`
   - `Test (Ruby 3.4)`
   - `Test (Ruby 4.0)`
   - `Changelog`
   - `Version`

## Troubleshooting

### Release workflow fails with "must point to commit on main"

You tagged a commit that isn't on the main branch. Delete the tag and re-tag a commit on main:

```bash
git tag -d vX.Y.Z              # Delete local tag
git push origin :vX.Y.Z        # Delete remote tag
git checkout main
git pull
git tag vX.Y.Z
git push origin vX.Y.Z
```

### "You do not have permission to push to this gem"

The RubyGems trusted publisher isn't configured, or the environment name doesn't match. Check the one-time setup steps above.

### Forgot to update CHANGELOG

Delete the tag, update CHANGELOG, amend the commit, re-tag:

```bash
git tag -d vX.Y.Z
git push origin :vX.Y.Z
# Update CHANGELOG.md
git add CHANGELOG.md
git commit --amend --no-edit
git push --force-with-lease origin main
git tag vX.Y.Z
git push origin vX.Y.Z
```

## Manual Release (Fallback)

If automation fails and you need to publish manually:

```bash
bundle exec rake release
```

This builds the gem and pushes to RubyGems using your local credentials.
