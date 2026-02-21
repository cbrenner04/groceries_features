# Agent Instructions for groceries_features

This is the end-to-end feature test suite for the Groceries application. Tests run via Capybara/Selenium against a live instance of the app.

## Commands

### Environment Setup
- `bundle install` - Install Ruby dependencies.
- Copy `config/env.yml.example` to `config/env.yml` and configure for your environment.

### Running Tests
- `rspec` - Run all feature tests locally against the default environment.
- `rspec spec/features/lists/lists_spec.rb` - Run a specific spec file.
- `rspec spec/features/lists/lists_spec.rb:42` - Run a single test at a specific line.
- `ENV=staging rspec` - Run tests against the staging environment.
- `DRIVER=poltergeist rspec` - Run tests headless.
- `bash run_tests.sh` - Run tests in parallel (handles setup/cleanup).
- `PARALLELS=10 bash run_tests.sh` - Run parallel tests with a specific process count.

### Linting
- `bundle exec rubocop` - Run RuboCop linting.
- `bundle exec rubocop -a` - Auto-fix safe linting issues.

## Tech Stack
- **Ruby:** 3.4.8
- **Testing:** RSpec 3.12, Capybara 3.39+, Selenium WebDriver 4.16+
- **Page Objects:** SitePrism 5.0+
- **Database Access:** Sequel 5.76+ with PostgreSQL (for test data setup)
- **Parallel Execution:** parallel_tests 5.0+
- **Browser:** Chrome (default), Poltergeist (headless)

## Project Structure

```
spec/
├── features/              # Feature test files
│   ├── list_items/        # Tests per list item type (book, grocery, music, simple, to-do)
│   ├── lists/             # List management tests
│   ├── completed_lists_spec.rb
│   ├── invite_spec.rb
│   ├── login_spec.rb
│   └── share_spec.rb
├── support/
│   ├── helpers/           # Shared test helpers (auth, data, wait, results, cleanup)
│   ├── models/            # Sequel-backed models for test data (User, List, ListItem, etc.)
│   ├── pages/             # SitePrism page objects for UI interactions
│   ├── shared_examples/   # Reusable RSpec shared example groups
│   └── scripts/           # Test infrastructure scripts
├── screenshots/           # Capybara failure screenshots
└── spec_helper.rb         # RSpec/Capybara configuration
config/
├── env.yml                # Environment config (not committed)
└── env.yml.example        # Template for env.yml
```

## Code Style Guidelines

### General Ruby
- **Indentation:** 2 spaces.
- **Naming:** `snake_case` for methods and variables; `CamelCase` for classes and modules.
- **Frozen String Literals:** Always include `# frozen_string_literal: true`.
- **Line Length:** Maximum 120 characters.
- **Strings:** Prefer double quotes.
- **Method Length:** Maximum 20 lines.

### Test Patterns
- **Page Object Pattern:** All UI interactions go through SitePrism page objects in `spec/support/pages/`. Use `SitePrism::Section` for repeated sub-components within a page.
- **Test Selectors:** Use `data-test-id` and `data-test-class` attributes to locate elements. Never use CSS classes or fragile selectors. Semantic selectors (`find('button', text: 'Save')`) are acceptable as a fallback.
- **Shared Examples:** Use `it_behaves_like` for behavior shared across list item types.
- **Data Setup:** Create test data directly in the database via Sequel models in `spec/support/models/`. Clean up after tests.
- **Authentication:** Use `AuthenticationHelper` for login/logout in test setup.
- **Waiting:** Use the custom `wait_for` helper for explicit waits. Capybara default wait is 3 seconds.

### Wait Strategies
```ruby
# Wait for element to be visible
expect(page).to have_selector('[data-test-id="loading"]', visible: true)

# Wait for element to disappear
expect(page).to have_no_selector('[data-test-id="loading"]')

# Wait for text to appear
expect(page).to have_text("List created successfully")
```

### Test Structure
```ruby
RSpec.describe "Feature Name", type: :feature do
  let(:user) { Models::User.new }
  let(:list) { Models::List.new(user_id: user.id, name: "Test") }

  before do
    login user
  end

  after do
    # cleanup
  end

  it "performs the expected action" do
    home_page.navigate_to_list(list)
    expect(list_page).to have_expected_element
  end
end
```

### Page Object with Sections
```ruby
class ListPage < SitePrism::Page
  set_url "/lists/{id}"

  element :list_name, '[data-test-id="list-name"]'
  element :add_item_button, '[data-test-id="add-item-button"]'
  sections :items, ItemSection, '[data-test-id="list-item"]'
end

class ItemSection < SitePrism::Section
  element :name, '[data-test-id="item-name"]'
  element :edit_button, '[data-test-id="edit-item"]'
  element :delete_button, '[data-test-id="delete-item"]'
end
```

## Configuration

- **Capybara window size:** 1728x960
- **Default wait time:** 3 seconds
- **Screenshot on failure:** Saved to `spec/screenshots/`
- **RSpec retry:** Configurable via environment; default 1 attempt
- **Environment targeting:** Set `ENV` variable to `staging` or `production`

## Code Review Checklist
- Page objects used for UI interactions.
- Proper wait strategies implemented (no `sleep`).
- Tests clean up their own data.
- Shared examples used where behavior is common across list types.
- `data-test-id` selectors used (not CSS classes).
- Test data created via Sequel models, not the UI.

## Guardrails
- Tests require a running Groceries application instance (client + service).
- Test data is created directly in the service database — do not modify production data.
- Results are posted to the `groceries_features_results` service when configured.
