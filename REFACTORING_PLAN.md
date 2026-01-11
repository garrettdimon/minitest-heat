# Minitest Heat Architecture Refactoring Plan

This plan outlines incremental improvements to reduce coupling and streamline the codebase. Each phase is self-contained and can be completed independently.

## Overview

**Goal:** Make the codebase more anti-fragile by reducing coupling, improving testability, and clarifying responsibilities.

**Principles:**
- Each phase should leave tests passing
- Changes are incremental and reversible
- Prefer dependency injection over singleton access
- Extract services for complex logic

---

## Phase 1: Inject Configuration into Issue Class

**Files:** `lib/minitest/heat/issue.rb`, `lib/minitest/heat_reporter.rb`

**Problem:** The `Issue` class directly accesses `Minitest::Heat.configuration`, creating a hidden dependency that makes testing difficult.

**Current code (issue.rb:122-130):**
```ruby
def slow_threshold
  Minitest::Heat.configuration.slow_threshold
end

def painfully_slow_threshold
  Minitest::Heat.configuration.painfully_slow_threshold
end
```

**Tasks:**
1. [ ] Add optional `configuration:` keyword argument to `Issue.initialize`
2. [ ] Default to `Minitest::Heat.configuration` for backwards compatibility
3. [ ] Store configuration as instance variable `@configuration`
4. [ ] Update `slow_threshold` and `painfully_slow_threshold` to use `@configuration`
5. [ ] Update `Issue.from_result` class method to accept and pass configuration
6. [ ] Update `HeatReporter#record` to pass configuration when creating issues
7. [ ] Add test that creates Issue with custom configuration to verify injection works
8. [ ] Run tests: `bundle exec rake test`

**Expected outcome:** Issue class can be tested with mock configuration without touching global state.

---

## Phase 2: Extract IssueClassifier Service

**Files:** New file `lib/minitest/heat/issue_classifier.rb`, update `lib/minitest/heat/issue.rb`

**Problem:** The `Issue#type` method has high cyclomatic complexity (6+ branches) and mixes classification logic with the domain model.

**Current code (issue.rb:93-109):**
```ruby
def type
  if error? && in_test?
    :broken
  elsif error?
    :error
  elsif skipped?
    :skipped
  elsif !passed?
    :failure
  elsif passed? && painful?
    :painful
  elsif passed? && slow?
    :slow
  else
    :success
  end
end
```

**Tasks:**
1. [ ] Create `lib/minitest/heat/issue_classifier.rb` with class `IssueClassifier`
2. [ ] Move classification logic to `IssueClassifier.classify(issue)` class method
3. [ ] IssueClassifier should accept issue and return symbol (:broken, :error, :skipped, :failure, :painful, :slow, :success)
4. [ ] Update `Issue#type` to delegate to `IssueClassifier.classify(self)`
5. [ ] Add require for issue_classifier in `lib/minitest/heat.rb`
6. [ ] Create `test/minitest/heat/issue_classifier_test.rb` with unit tests for each classification case
7. [ ] Run tests: `bundle exec rake test`

**Expected outcome:** Classification logic is isolated, testable, and can be modified without changing Issue class.

---

## Phase 3: Extract LocationClassifier Module

**Files:** New file `lib/minitest/heat/location_classifier.rb`, update `lib/minitest/heat/location.rb`

**Problem:** Location classification predicates (test_file?, project_file?, etc.) are verbose and could be reused elsewhere.

**Current code (location.rb:137-169):**
```ruby
def project_file?
  path_string.start_with?(project_directory)
end

def bundled_file?
  path_string.include?('/gems/')
end

def test_file?
  path_string.include?('/test/')
end
# ... more predicates
```

**Tasks:**
1. [ ] Create `lib/minitest/heat/location_classifier.rb` module
2. [ ] Extract path classification methods into module methods that accept a path string
3. [ ] Include or delegate to LocationClassifier from Location class
4. [ ] Ensure Backtrace location filtering still works correctly
5. [ ] Add require in `lib/minitest/heat.rb`
6. [ ] Add tests for LocationClassifier module
7. [ ] Run tests: `bundle exec rake test`

**Expected outcome:** File classification logic is centralized and reusable.

---

## Phase 4: Dependency Injection for Output Formatters

**Files:** `lib/minitest/heat/output/issue.rb`, `lib/minitest/heat/output/source_code.rb`

**Problem:** Output formatters instantiate domain objects (Source) directly, creating tight coupling.

**Current code (output/issue.rb:116):**
```ruby
source = Minitest::Heat::Source.new(filename, line_number: line_number)
```

**Tasks:**
1. [ ] Update `Output::Issue.initialize` to accept optional `source_factory:` parameter
2. [ ] Default factory to `Minitest::Heat::Source` for backwards compatibility
3. [ ] Use factory instead of direct instantiation
4. [ ] Apply same pattern to `Output::SourceCode` if needed
5. [ ] Update `Output::Issue` to accept pre-built `Backtrace` formatter via constructor
6. [ ] Add tests verifying formatters work with injected dependencies
7. [ ] Run tests: `bundle exec rake test`

**Expected outcome:** Output formatters can be tested in isolation with mock dependencies.

---

## Phase 5: Split Output Module into Three Concerns

**Files:** `lib/minitest/heat/output.rb`, new files for extracted classes

**Problem:** Output class (167 lines) handles orchestration, formatting decisions, AND token printing.

**Tasks:**
1. [ ] Create `lib/minitest/heat/output/token_printer.rb` - handles IO operations (print, puts, newline)
2. [ ] Create `lib/minitest/heat/output/orchestrator.rb` - decides what to display and when
3. [ ] Refactor `Output` to delegate to these new classes
4. [ ] Move `show?` logic to Orchestrator
5. [ ] Move `print_token`, `puts`, `newline` to TokenPrinter
6. [ ] Keep Output as the public API that composes these classes
7. [ ] Update requires in `lib/minitest/heat.rb`
8. [ ] Add tests for TokenPrinter and Orchestrator
9. [ ] Run tests: `bundle exec rake test`

**Expected outcome:** Clear separation of concerns makes each class easier to understand and test.

---

## Phase 6: TokenBuilder Helper (Optional)

**Files:** New file `lib/minitest/heat/output/token_builder.rb`

**Problem:** Multiple output classes repeat similar token array building patterns.

**Tasks:**
1. [ ] Create `TokenBuilder` class with fluent interface
2. [ ] Implement `add(style, content)` method
3. [ ] Implement `add_if(condition, style, content)` method
4. [ ] Implement `spacer` and `newline` methods
5. [ ] Implement `tokens` method to return built array
6. [ ] Refactor `Output::Results#summary_tokens` to use TokenBuilder
7. [ ] Refactor `Output::Map` token building to use TokenBuilder
8. [ ] Run tests: `bundle exec rake test`

**Expected outcome:** Cleaner, more declarative token construction across output classes.

---

## Testing Strategy

After each phase:
1. Run `bundle exec rake test` - all existing tests should pass
2. Run `bundle exec rubocop` - code style should be maintained
3. Verify the gem still works: `bundle exec ruby -Ilib -rminitest/heat -e "puts 'loaded'"`

## Verification

When complete, the architecture should have:
- [ ] No direct `Minitest::Heat.configuration` access in domain classes (except defaults)
- [ ] Issue class under 150 lines
- [ ] IssueClassifier as standalone testable service
- [ ] LocationClassifier module for file type detection
- [ ] Output formatters accepting dependencies via constructor
- [ ] Clear separation in Output between orchestration and printing

---

## Getting Started

To begin refactoring with Claude Code:

```bash
git checkout claude/streamline-gem-architecture-LsC28
git pull origin claude/streamline-gem-architecture-LsC28
```

Then ask Claude Code:
> "Let's work through the refactoring plan in REFACTORING_PLAN.md. Start with Phase 1."

Claude Code will guide you through each task, making changes incrementally and running tests to verify.
