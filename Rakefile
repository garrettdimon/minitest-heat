# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

task default: :test

namespace :release do
  desc 'Run bundle-audit to check for vulnerable dependencies'
  task :audit do
    puts '🔒 Running security audit...'
    sh 'bundle exec bundle-audit check --update'
  end

  desc 'Validate version, changelog, and git state before release'
  task :check do
    require_relative 'lib/minitest/heat/version'
    errors = ReleaseChecker.new(Minitest::Heat::VERSION).validate
    if errors.any?
      puts "\n❌ Release check failed:"
      errors.each { |e| puts "   - #{e}" }
      exit 1
    else
      puts '✅ All release checks passed!'
    end
  end

  desc 'Run all pre-release checks (tests, lint, audit, release:check)'
  task preflight: %i[test lint audit check] do
    puts "\n🚀 All preflight checks passed! Ready to release."
  end
end

# Validates release readiness
class ReleaseChecker
  def initialize(version)
    @version = version
    @errors = []
  end

  def validate
    puts "📋 Checking release readiness for v#{@version}..."
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

desc 'Run RuboCop linter'
task :lint do
  puts '🔍 Running RuboCop...'
  sh 'bundle exec rubocop'
end
