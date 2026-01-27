# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

task default: :test

# rubocop:disable Metrics/BlockLength
namespace :release do
  desc 'Run bundle-audit to check for vulnerable dependencies'
  task :audit do
    puts 'Running security audit...'
    sh 'bundle exec bundle-audit check --update'
  end

  desc 'Validate version, changelog, and git state before release'
  task :check do
    require_relative 'lib/minitest/heat/version'
    errors = ReleaseChecker.new(Minitest::Heat::VERSION).validate
    if errors.any?
      puts "\nRelease check failed:"
      errors.each { |e| puts "  - #{e}" }
      exit 1
    else
      puts 'All release checks passed.'
    end
  end

  desc 'Run all pre-release checks (tests, audit, release:check)'
  task preflight: %i[test audit check] do
    puts "\nAll preflight checks passed. Ready to release."
  end

  desc 'Build gem locally and show contents (dry run)'
  task :dry_run do
    require_relative 'lib/minitest/heat/version'
    DryRun.new(Minitest::Heat::VERSION).run
  end
end
# rubocop:enable Metrics/BlockLength

# Validates release readiness
class ReleaseChecker
  def initialize(version)
    @version = version
    @errors = []
  end

  def validate
    puts "Checking release readiness for v#{@version}..."
    check_version_format
    check_changelog
    check_git_clean
    check_main_branch
    @errors
  end

  private

  def check_version_format
    return if @version.match?(/\A\d+\.\d+\.\d+\z/)

    @errors << "Version '#{@version}' is not valid semver (expected X.Y.Z)"
  end

  def check_changelog
    changelog = File.read('CHANGELOG.md')
    return if changelog.include?("[#{@version}]")

    @errors << "CHANGELOG.md has no entry for version #{@version}"
  end

  def check_git_clean
    return if `git status --porcelain`.empty?

    @errors << 'Working directory has uncommitted changes'
  end

  def check_main_branch
    current_branch = `git branch --show-current`.strip
    return if current_branch == 'main'

    @errors << "Not on main branch (currently on '#{current_branch}')"
  end
end

# Builds gem and displays contents without publishing
class DryRun
  def initialize(version)
    @version = version
    @gem_file = "minitest-heat-#{version}.gem"
  end

  def run
    build || abort('Gem build failed')
    show_contents
    show_size
  ensure
    cleanup if File.exist?(@gem_file)
  end

  private

  def build
    puts "Building #{@gem_file}..."
    system 'gem build minitest-heat.gemspec --silent'
  end

  def show_contents
    puts "\nGem contents:"
    system "tar -tf #{@gem_file}"
  end

  def show_size
    size = File.size(@gem_file)
    puts "\nGem size: #{(size / 1024.0).round(1)} KB"
  end

  def cleanup
    File.delete(@gem_file)
    puts "Cleaned up #{@gem_file}"
  end
end
