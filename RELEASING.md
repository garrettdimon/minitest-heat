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

### 3. Commit the Release

```bash
git add lib/minitest/heat/version.rb CHANGELOG.md
git commit -m "Release vX.Y.Z"
```

### 4. Create and Push Tag

```bash
git tag vX.Y.Z
git push origin main
git push origin vX.Y.Z
```

### 5. Build and Publish

```bash
bundle exec rake release
```

This command:
- Builds the `.gem` file
- Pushes to [RubyGems.org](https://rubygems.org/gems/minitest-heat)
- Creates a GitHub release (if configured)

### 6. Verify

- Check [RubyGems](https://rubygems.org/gems/minitest-heat) for the new version
- Verify the gem installs correctly: `gem install minitest-heat -v X.Y.Z`

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
