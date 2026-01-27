# Releasing Minitest Heat

This document describes the release process for maintainers.

## Versioning Policy

Minitest Heat follows [Semantic Versioning](https://semver.org/):

- **MAJOR** (x.0.0): Breaking changes to the public API or configuration
- **MINOR** (0.x.0): New features, new configuration options, deprecations
- **PATCH** (0.0.x): Bug fixes, performance improvements, documentation updates

### What Constitutes a Breaking Change?

- Removing or renaming public classes/methods
- Changing method signatures in incompatible ways
- Changing default configuration values that affect behavior
- Dropping support for Ruby versions (document in CHANGELOG as "Breaking Changes")

## Pre-Release Checklist

Run the preflight task to verify everything automatically:

```bash
bundle exec rake release:preflight
```

This runs all checks in sequence:
- Tests (`rake test`)
- Linting (`rake lint`)
- Security audit (`rake release:audit`)
- Release validation (`rake release:check`)

Or run individual checks:

```bash
bundle exec rake test                # Run test suite
bundle exec rake lint                # Run RuboCop
bundle exec rake release:audit       # Check for vulnerable dependencies
bundle exec rake release:check       # Validate version, changelog, git state
```

The release:check task verifies:
- Version follows semver format (X.Y.Z)
- CHANGELOG.md has an entry for the version
- Working directory is clean (no uncommitted changes)
- You're on the main branch

## Release Process

Releases are automated via GitHub Actions. When you push a version tag, the workflow:
1. Runs all verification checks (tests, lint, security audit)
2. Builds and publishes the gem to RubyGems (via trusted publishing)
3. Creates a GitHub Release with changelog excerpt

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

### Changed
- Change description

### Fixed
- Bug fix description
```

### 3. Run Preflight Checks

```bash
bundle exec rake release:preflight
```

### 4. Commit and Tag

```bash
git add lib/minitest/heat/version.rb CHANGELOG.md
git commit -m "Release vX.Y.Z"
git push origin main
git tag vX.Y.Z
git push origin vX.Y.Z
```

GitHub Actions takes over from here and handles publishing automatically.

### 5. Verify

- Watch the [Actions tab](https://github.com/garrettdimon/minitest-heat/actions) for workflow completion
- Check [RubyGems](https://rubygems.org/gems/minitest-heat) for the new version
- Verify the [GitHub Release](https://github.com/garrettdimon/minitest-heat/releases) was created

### Manual Release (Fallback)

If automated publishing fails, you can publish manually:

```bash
bundle exec rake release
```

Or trigger the workflow manually from the Actions tab using the "Run workflow" button.

## One-Time Setup

### RubyGems Trusted Publishing

The release workflow uses OIDC trusted publishing to push gems without storing API keys. This requires one-time setup:

1. Go to [rubygems.org/profile/oidc/pending_trusted_publishers](https://rubygems.org/profile/oidc/pending_trusted_publishers)
2. Add a new trusted publisher:
   - **Gem name:** `minitest-heat`
   - **GitHub repository owner:** `garrettdimon`
   - **GitHub repository name:** `minitest-heat`
   - **GitHub workflow filename:** `release.yml`
   - **Environment:** `rubygems`

### GitHub Environment

Create a `rubygems` environment for deployment protection:

1. Go to repository Settings > Environments
2. Create new environment named `rubygems`
3. Optionally add required reviewers or deployment branches

## Troubleshooting

### "You do not have permission to push to this gem"

You need to be added as an owner on RubyGems:

```bash
gem owner minitest-heat --add EMAIL
```

### "Tag already exists"

If you need to re-release (e.g., after fixing a mistake):

```bash
git tag -d vX.Y.Z           # Delete local tag
git push origin :vX.Y.Z     # Delete remote tag
# Fix the issue, then re-tag
git tag vX.Y.Z
git push origin vX.Y.Z
```

### Tests Fail on Release

Never release with failing tests. Fix the issues first:

```bash
bundle exec rake test
```

### Bundle-Audit Reports Vulnerabilities

Update dependencies and re-run:

```bash
bundle update
bundle exec bundle-audit check --update
```

If a vulnerability is in a development dependency only, document and proceed with caution.

### Forgot to Update CHANGELOG

If you've already tagged but forgot the CHANGELOG:

1. Delete the tag (see above)
2. Update CHANGELOG
3. Amend the commit: `git commit --amend`
4. Re-tag and push

## Post-Release

After a successful release:

1. Add a new `[Unreleased]` section to CHANGELOG.md
2. Consider announcing on relevant channels (Twitter, Ruby Weekly, etc.)
3. Close any GitHub issues resolved by this release
