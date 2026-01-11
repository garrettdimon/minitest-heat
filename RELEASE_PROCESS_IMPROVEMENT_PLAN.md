# Release Process Improvement Plan

This document outlines a phased approach to improving the gem release process for minitest-heat. Each phase is designed to be a focused, self-contained PR that builds upon previous phases.

## Current State Analysis

### What Works Well
- **Version management**: Single source of truth in `lib/minitest/heat/version.rb`
- **CHANGELOG format**: Follows [Keep a Changelog](https://keepachangelog.com/) conventions
- **Gemspec metadata**: Well-configured with all important URIs (changelog, bugs, docs, source)
- **Security**: MFA required for RubyGems publishing
- **CI matrix**: Tests across Ruby 3.2, 3.3, 3.4, and 4.0 preview

### Current Pain Points
1. **Minimal documentation**: Release instructions are a single sentence in README
2. **No pre-release validation**: Tests/linting aren't required before publishing
3. **Fully manual process**: Easy to forget steps or make mistakes
4. **No GitHub Releases**: Users must check CHANGELOG manually for release notes
5. **No automation**: Every release requires manual command execution

---

## Phase 1: Release Documentation

**Goal**: Provide clear, comprehensive documentation for maintainers and contributors.

**PR Scope**: Documentation only, no code changes.

### Deliverables

#### 1.1 Create `RELEASING.md`

A dedicated release guide covering:

```markdown
# Releasing minitest-heat

## Versioning Policy

This gem follows [Semantic Versioning](https://semver.org/):

- **MAJOR** (x.0.0): Breaking changes to public API
  - Removing public methods or classes
  - Changing method signatures in incompatible ways
  - Dropping support for Ruby versions

- **MINOR** (0.x.0): New features, backwards compatible
  - Adding new public methods or classes
  - Adding new configuration options
  - Deprecating features (without removing)

- **PATCH** (0.0.x): Bug fixes, backwards compatible
  - Fixing bugs without changing public API
  - Performance improvements
  - Documentation updates

## Pre-Release Checklist

Before releasing, verify:

- [ ] All CI checks pass on main branch
- [ ] CHANGELOG.md has entries under `[Unreleased]`
- [ ] No uncommitted changes in working directory
- [ ] You have RubyGems push credentials configured
- [ ] You have 2FA device ready (MFA required)

## Release Steps

### 1. Prepare the Release

```bash
# Ensure you're on main with latest changes
git checkout main
git pull origin main

# Verify CI status
gh run list --limit 5
```

### 2. Update Version

Edit `lib/minitest/heat/version.rb`:

```ruby
module Minitest
  module Heat
    VERSION = 'X.Y.Z'  # Update this
  end
end
```

### 3. Update CHANGELOG

Move items from `[Unreleased]` to a new version section:

```markdown
## [Unreleased]
<!-- Move content below -->

## [X.Y.Z] - YYYY-MM-DD

### Added
- New feature description

### Changed
- Change description

### Fixed
- Bug fix description
```

### 4. Commit Release Preparation

```bash
git add lib/minitest/heat/version.rb CHANGELOG.md
git commit -m "Release vX.Y.Z"
```

### 5. Run Release

```bash
bundle exec rake release
```

This command will:
- Build the gem
- Create a git tag `vX.Y.Z`
- Push the commit and tag to GitHub
- Push the gem to RubyGems.org

### 6. Post-Release Verification

- [ ] Verify gem appears on [RubyGems](https://rubygems.org/gems/minitest-heat)
- [ ] Verify tag exists on [GitHub](https://github.com/garrettdimon/minitest-heat/tags)
- [ ] Consider creating a GitHub Release with CHANGELOG excerpt

## Troubleshooting

### "You do not have permission to push"
Ensure you have write access to the repository and RubyGems credentials are configured.

### "MFA required"
Have your 2FA device ready. RubyGems will prompt during `gem push`.

### Release failed mid-way
If the gem was pushed but tags weren't:
```bash
git tag vX.Y.Z
git push origin vX.Y.Z
```
```

#### 1.2 Update README.md

Replace the current release section with a reference to RELEASING.md:

```markdown
## Releasing

See [RELEASING.md](RELEASING.md) for detailed release instructions.
```

### Success Criteria
- Contributors can follow RELEASING.md without additional guidance
- Versioning expectations are clearly documented
- Common issues have documented solutions

---

## Phase 2: Pre-Release Validation

**Goal**: Prevent broken releases by adding automated checks that run before publishing.

**PR Scope**: Rakefile enhancements and supporting scripts.

### Deliverables

#### 2.1 Add Pre-flight Rake Task

Add to `Rakefile`:

```ruby
namespace :release do
  desc 'Run all pre-release checks'
  task preflight: [:test, :rubocop, :audit, :check]

  desc 'Verify release readiness'
  task :check do
    require_relative 'lib/minitest/heat/version'

    errors = []

    # Check version format
    version = Minitest::Heat::VERSION
    unless version.match?(/\A\d+\.\d+\.\d+(-[\w.]+)?\z/)
      errors << "Invalid version format: #{version}"
    end

    # Check CHANGELOG has unreleased content or version entry
    changelog = File.read('CHANGELOG.md')
    unless changelog.include?("[#{version}]") || changelog.include?('[Unreleased]')
      errors << "CHANGELOG.md missing entry for version #{version}"
    end

    # Check for uncommitted changes
    unless `git status --porcelain`.empty?
      errors << "Uncommitted changes in working directory"
    end

    # Check we're on main branch
    current_branch = `git branch --show-current`.strip
    unless current_branch == 'main'
      errors << "Not on main branch (currently on: #{current_branch})"
    end

    if errors.any?
      puts "\n❌ Release check failed:"
      errors.each { |e| puts "  • #{e}" }
      exit 1
    else
      puts "\n✅ All release checks passed!"
    end
  end

  desc 'Run security audit'
  task :audit do
    sh 'bundle exec bundle-audit check --update'
  end

  desc 'Run RuboCop'
  task :rubocop do
    sh 'bundle exec rubocop'
  end
end
```

#### 2.2 Add Version Bump Helper (Optional)

Create `bin/bump`:

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

# Usage: bin/bump [major|minor|patch]

require_relative '../lib/minitest/heat/version'

BUMP_TYPE = ARGV[0]&.downcase

unless %w[major minor patch].include?(BUMP_TYPE)
  puts "Usage: bin/bump [major|minor|patch]"
  puts "Current version: #{Minitest::Heat::VERSION}"
  exit 1
end

current = Minitest::Heat::VERSION
major, minor, patch = current.split('.').map(&:to_i)

new_version = case BUMP_TYPE
              when 'major' then "#{major + 1}.0.0"
              when 'minor' then "#{major}.#{minor + 1}.0"
              when 'patch' then "#{major}.#{minor}.#{patch + 1}"
              end

version_file = File.expand_path('../lib/minitest/heat/version.rb', __dir__)
content = File.read(version_file)
new_content = content.gsub(/VERSION = ['"].*['"]/, "VERSION = '#{new_version}'")

File.write(version_file, new_content)

puts "Bumped version: #{current} → #{new_version}"
puts "\nNext steps:"
puts "  1. Update CHANGELOG.md"
puts "  2. git add -A && git commit -m 'Release v#{new_version}'"
puts "  3. bundle exec rake release"
```

### Success Criteria
- `rake release:preflight` catches common issues before release
- `rake release:check` validates version and changelog
- Version bumping is less error-prone

---

## Phase 3: GitHub Actions Release Automation

**Goal**: Automate gem publishing when a version tag is pushed, with full CI verification.

**PR Scope**: New GitHub Actions workflow and minor Rakefile updates.

### Deliverables

#### 3.1 Create Release Workflow

Create `.github/workflows/release.yml`:

```yaml
name: Release

on:
  push:
    tags:
      - 'v*'

permissions:
  contents: write
  id-token: write

jobs:
  # First, verify all tests pass
  verify:
    name: Verify
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.4'
          bundler-cache: true

      - name: Run tests
        run: bundle exec rake test

      - name: Run RuboCop
        run: bundle exec rubocop

      - name: Security audit
        run: |
          bundle exec bundle-audit check --update

  # Build and publish to RubyGems
  publish:
    name: Publish to RubyGems
    needs: verify
    runs-on: ubuntu-latest
    environment: rubygems

    steps:
      - uses: actions/checkout@v4

      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.4'
          bundler-cache: true

      - name: Verify version matches tag
        run: |
          TAG_VERSION="${GITHUB_REF#refs/tags/v}"
          GEM_VERSION=$(ruby -r ./lib/minitest/heat/version -e "puts Minitest::Heat::VERSION")
          if [ "$TAG_VERSION" != "$GEM_VERSION" ]; then
            echo "Tag version ($TAG_VERSION) doesn't match gem version ($GEM_VERSION)"
            exit 1
          fi

      - name: Build gem
        run: gem build minitest-heat.gemspec

      - name: Publish to RubyGems
        uses: rubygems/release-gem@v1
        # Uses OIDC trusted publishing (no API key needed)
        # Requires RubyGems trusted publisher configuration

  # Create GitHub Release with changelog excerpt
  github-release:
    name: Create GitHub Release
    needs: publish
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Extract changelog for version
        id: changelog
        run: |
          VERSION="${GITHUB_REF#refs/tags/v}"
          # Extract the section for this version from CHANGELOG.md
          NOTES=$(awk "/## \[$VERSION\]/{flag=1; next} /## \[/{flag=0} flag" CHANGELOG.md)
          echo "notes<<EOF" >> $GITHUB_OUTPUT
          echo "$NOTES" >> $GITHUB_OUTPUT
          echo "EOF" >> $GITHUB_OUTPUT

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v2
        with:
          body: |
            ## What's Changed

            ${{ steps.changelog.outputs.notes }}

            ## Installation

            ```bash
            gem install minitest-heat
            ```

            Or add to your Gemfile:

            ```ruby
            gem 'minitest-heat', '~> ${{ github.ref_name }}'
            ```
          generate_release_notes: true
```

#### 3.2 Configure RubyGems Trusted Publishing

Document in RELEASING.md the one-time setup for trusted publishing:

1. Go to RubyGems.org → Your gems → minitest-heat → Trusted publishers
2. Add GitHub Actions publisher:
   - Repository owner: `garrettdimon`
   - Repository name: `minitest-heat`
   - Workflow filename: `release.yml`
   - Environment: `rubygems`

#### 3.3 Create GitHub Environment

Document creation of `rubygems` environment in GitHub repository settings for deployment protection.

### Success Criteria
- Pushing a version tag triggers automated release
- CI must pass before gem is published
- GitHub Releases are automatically created with changelog notes
- No manual RubyGems credentials needed (OIDC trusted publishing)

---

## Phase 4: Enhanced Developer Experience

**Goal**: Quality-of-life improvements for ongoing maintenance.

**PR Scope**: Additional tooling and documentation.

### Deliverables

#### 4.1 Release Dry-Run Task

Add to Rakefile:

```ruby
namespace :release do
  desc 'Perform a dry-run release (build gem, show what would happen)'
  task :dry_run do
    require_relative 'lib/minitest/heat/version'
    version = Minitest::Heat::VERSION

    puts "🔍 Dry-run release for v#{version}\n\n"

    # Run preflight
    Rake::Task['release:preflight'].invoke

    puts "\n📦 Building gem..."
    sh 'gem build minitest-heat.gemspec'

    gem_file = "minitest-heat-#{version}.gem"
    if File.exist?(gem_file)
      puts "\n✅ Gem built successfully: #{gem_file}"
      puts "   Size: #{File.size(gem_file)} bytes"

      # Show contents
      puts "\n📋 Gem contents:"
      sh "gem spec #{gem_file} files | head -20"

      # Cleanup
      File.delete(gem_file)
      puts "\n🧹 Cleaned up #{gem_file}"
    end

    puts "\n" + "="*50
    puts "Dry run complete. To release for real, run:"
    puts "  git tag v#{version}"
    puts "  git push origin v#{version}"
  end
end
```

#### 4.2 CHANGELOG Validation

Add changelog linting to CI:

```yaml
# Add to .github/workflows/main.yml
- name: Validate CHANGELOG
  run: |
    # Ensure CHANGELOG follows Keep a Changelog format
    if ! grep -q "## \[Unreleased\]" CHANGELOG.md; then
      echo "CHANGELOG.md must have an [Unreleased] section"
      exit 1
    fi
```

#### 4.3 Version Consistency Check

Add to CI to ensure version file and any references stay in sync:

```ruby
# In Rakefile
desc 'Verify version consistency across files'
task :verify_version do
  require_relative 'lib/minitest/heat/version'
  version = Minitest::Heat::VERSION

  # Check gemspec can load version
  spec = Gem::Specification.load('minitest-heat.gemspec')
  unless spec.version.to_s == version
    abort "Gemspec version mismatch: #{spec.version} vs #{version}"
  end

  puts "✅ Version #{version} is consistent"
end
```

### Success Criteria
- Maintainers can preview releases before publishing
- CI catches CHANGELOG formatting issues early
- Version inconsistencies are caught before release

---

## Implementation Timeline

| Phase | Focus | Estimated Effort | Dependencies |
|-------|-------|------------------|--------------|
| 1 | Documentation | ~1 hour | None |
| 2 | Pre-release validation | ~2 hours | Phase 1 (for docs) |
| 3 | GitHub Actions automation | ~2-3 hours | Phases 1-2, RubyGems setup |
| 4 | Developer experience | ~1-2 hours | Phases 1-3 |

## Migration Notes

### For Existing Maintainers

After Phase 3 is complete, the release workflow changes from:

**Before:**
```bash
# Edit version.rb
# Edit CHANGELOG.md
git commit -am "Release vX.Y.Z"
bundle exec rake release
```

**After:**
```bash
# Edit version.rb
# Edit CHANGELOG.md
git commit -am "Release vX.Y.Z"
git push origin main
git tag vX.Y.Z
git push origin vX.Y.Z
# Automation handles the rest!
```

### Rollback Plan

Each phase can be reverted independently:
- Phase 1: Delete RELEASING.md, restore README
- Phase 2: Remove rake tasks from Rakefile
- Phase 3: Delete workflow file, return to manual `rake release`
- Phase 4: Remove additional rake tasks

---

## Open Questions

1. **Trusted Publishing**: Does the RubyGems account have trusted publishing enabled, or should we use API key authentication instead?

2. **Branch Protection**: Should we require PRs for releases, or allow direct pushes to main for version bumps?

3. **Pre-release Versions**: Do we need support for alpha/beta/rc versions (e.g., `2.0.0-beta.1`)?

4. **Changelog Automation**: Would tools like `github-changelog-generator` or `release-please` be beneficial, or is manual changelog preferred?

---

## References

- [RubyGems Trusted Publishing](https://guides.rubygems.org/trusted-publishing/)
- [Keep a Changelog](https://keepachangelog.com/)
- [Semantic Versioning](https://semver.org/)
- [Bundler Gem Tasks](https://bundler.io/guides/creating_gem.html#releasing-the-gem)
- [GitHub Actions for Ruby](https://github.com/ruby/setup-ruby)
