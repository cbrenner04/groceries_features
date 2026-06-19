# AGENTS.md — groceries_features

---

# 🚨 Repository Operating Rules (MANDATORY)

These rules extend the root AGENTS.md and must be followed.

## Priority Order
1. Active Spec (if present)
2. Root AGENTS.md
3. This file

## Core Rules
- You MUST follow the active spec exactly
- Do NOT expand or reinterpret scope
- Do NOT modify client or service code
- Do NOT change API behavior
- Do NOT read additional files unless required by the spec

---

## Execution Modes

### PLAN MODE
- Identify:
  - Feature files to modify
  - Page objects involved
  - Test data requirements
- Do NOT modify files
- Call out:
  - Required test data
  - External dependencies (client/service behavior)

### PATCH MODE
- Modify ONLY files listed in the spec
- Execute steps exactly as written
- Do NOT add, remove, or reorder steps
- If a step is unclear: STOP and ask

---

## 📄 Spec Integration

- All non-trivial work must be driven by a spec in `/specs/`
- This repository executes ONLY its portion of the spec
- Ignore spec steps for other repositories unless instructed

### File Scope Enforcement
- Only modify files explicitly listed in the spec
- If additional files seem required:
  - STOP
  - ASK before proceeding

---

## 🔒 Change Boundaries

- Do NOT modify:
  - Application code (client or service)
  - API contracts
  - Database schema
- Do NOT rename or move files unless specified
- Do NOT update unrelated tests

---

## 🧪 Test Data Rules (CRITICAL)

- Test data is created directly in the service database via Sequel
- Do NOT modify existing production data
- Always clean up created data after tests

### Safety
- Prefer creating new records over modifying existing ones
- Avoid shared/global state between tests
- Ensure tests are isolated and repeatable

---

## 🎯 Selector Rules (CRITICAL)

- MUST use:
  - `data-test-id`
  - `data-test-class`
- NEVER use:
  - CSS classes
  - brittle DOM structure selectors

Fallback:
- Semantic selectors (e.g., `find('button', text: 'Save')`) only if necessary

---

## ⏱️ Waiting Rules

- Do NOT use `sleep`
- Use:
  - Capybara matchers (`have_selector`, `have_text`)
  - `wait_for` helper

---

## Commands

### Environment Setup
```bash
bundle install
```

* Copy `config/env.yml.example` → `config/env.yml`

---

### Running Tests

```bash
rspec
rspec spec/features/lists/lists_spec.rb
rspec spec/features/lists/lists_spec.rb:42
ENV=staging rspec
HEADLESS=true rspec
bash run_tests.sh
PARALLELS=10 bash run_tests.sh
```

---

### Linting

```bash
bundle exec rubocop
bundle exec rubocop -a
```

---

## Required After Changes (PATCH MODE)

```bash
bundle exec rubocop
```

* Do NOT run full test suite unless specified in the spec

---

## Tech Stack

* Ruby 3.4.8
* RSpec, Capybara, Selenium
* SitePrism (Page Objects)
* Sequel (DB access)
* parallel_tests

---

## Project Structure

```
spec/
├── features/
├── support/
│   ├── helpers/
│   ├── models/
│   ├── pages/
│   ├── shared_examples/
│   └── scripts/
├── screenshots/
└── spec_helper.rb

config/
├── env.yml
└── env.yml.example
```

---

## Test Patterns

### Page Objects

* All UI interactions MUST go through SitePrism page objects
* Use `SitePrism::Section` for repeated components

### Data Setup

* Use Sequel models in `spec/support/models/`
* Do NOT create data via UI unless explicitly required

### Authentication

* Use `AuthenticationHelper`

### Shared Behavior

* Use `it_behaves_like` for shared logic

---

## Testing Standards

### Rules

* Only modify or add tests if required by the spec
* Do NOT expand test scope
* Do NOT rewrite tests to match unintended behavior

### Coverage

* Maintain high coverage expectations
* Ensure new behavior is tested

---

## Configuration

* Window size: 1728x960
* Default wait: 3 seconds
* Screenshots on failure → `spec/screenshots/`
* Retry: configurable
* ENV targeting via `ENV`

---

## Code Review Checklist

* Page objects used correctly
* No `sleep` usage
* Proper wait strategies
* Data cleaned up
* Correct selectors used
* Test data created via Sequel

---

## Do NOT

* Modify application code (client/service)
* Change API behavior
* Use brittle selectors
* Leave test data behind
* Commit changes unless instructed
