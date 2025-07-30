# Feature Testing Development Guidelines

This document outlines the development standards, patterns, and guardrails for the Capybara/RSpec feature testing suite.

## Technology Stack

- **Testing Framework:** RSpec
- **Browser Automation:** Capybara
- **Drivers:** Selenium WebDriver (Chrome), Poltergeist (headless)
- **Page Objects:** SitePrism
- **Database:** Sequel for direct database access
- **Environment:** Envyable for configuration management

## Test Structure

### Directory Organization

```
spec/
├── features/              # Feature test files
│   ├── lists/            # List-related features
│   ├── list_items/       # List item features
│   └── users/            # User-related features
├── support/               # Test support files
│   ├── helpers/          # Test helpers
│   ├── models/           # Test models
│   ├── pages/            # Page objects
│   └── shared_examples/  # Shared test patterns
├── output/               # Test output files
├── screenshots/          # Failure screenshots
└── tmp/                  # Temporary test files
```

### File Naming Conventions

- Feature files: `feature_name_spec.rb`
- Page objects: `page_name.rb`
- Helpers: `helper_name.rb`
- Models: `model_name.rb`

## Test Configuration

### Capybara Setup

- Use Selenium WebDriver for Chrome by default
- Use Poltergeist for headless testing
- Window size: 1280x743
- Screenshot on failure enabled
- Automatic screenshot cleanup

### RSpec Configuration

- Use RSpec retry for flaky tests (default: 3 retries)
- Use parallel test execution support
- Use proper test isolation
- Use database cleanup after tests

## Test Patterns

### Page Object Pattern

Use SitePrism for page objects to encapsulate page interactions:

```ruby
class HomePage < SitePrism::Page
  set_url '/'
  
  element :lists_link, '[data-test-id="lists-link"]'
  element :new_list_button, '[data-test-id="new-list-button"]'
  
  def navigate_to_lists
    lists_link.click
  end
  
  def create_new_list
    new_list_button.click
  end
end
```

### Test Setup Pattern

```ruby
RSpec.describe 'List Management', type: :feature do
  let(:user) { create_user }
  let(:list) { create_list(user: user) }
  
  before do
    sign_in(user)
  end
  
  it 'creates a new list' do
    # Test implementation
  end
end
```

### Shared Examples

Use shared examples for common patterns:

```ruby
RSpec.shared_examples 'list item behavior' do |list_type|
  it 'allows adding items' do
    # Common test logic
  end
  
  it 'allows editing items' do
    # Common test logic
  end
end
```

## Test Data Management

### Data Helpers

Use data helpers for creating test data:

```ruby
module DataHelper
  def create_user(attributes = {})
    # User creation logic
  end
  
  def create_list(attributes = {})
    # List creation logic
  end
end
```

### Database Cleanup

- Use database cleanup after each test
- Use proper test isolation
- Use transactions when possible
- Clean up test data after suite

## Test Selectors

### Best Practices

- Use `data-test-id` attributes for reliable selectors
- Avoid using CSS classes for test selectors
- Use semantic selectors when possible
- Use proper wait strategies

### Selector Examples

```ruby
# Good - using data-test-id
find('[data-test-id="list-item"]')

# Good - using semantic selectors
find('button', text: 'Save')
find('input[name="list_name"]')

# Avoid - using CSS classes
find('.list-item')
```

## Wait Strategies

### Explicit Waits

Use explicit waits for async operations:

```ruby
# Wait for element to be visible
expect(page).to have_selector('[data-test-id="loading"]', visible: true)

# Wait for element to disappear
expect(page).to have_no_selector('[data-test-id="loading"]')

# Wait for text to appear
expect(page).to have_text('List created successfully')
```

### Implicit Waits

Configure Capybara for reasonable implicit waits:

```ruby
Capybara.default_max_wait_time = 5
```

## Test Environment

### Environment Configuration

- Use Envyable for environment configuration
- Use proper database configuration
- Use proper host configuration
- Use parallel test execution support

### Database Access

- Use Sequel for direct database access
- Use proper connection management
- Use transactions for test isolation
- Use proper cleanup strategies

## Test Execution

### Running Tests

```bash
# Run all feature tests
rspec

# Run specific feature
rspec spec/features/lists/grocery_lists_spec.rb

# Run headless tests
DRIVER=poltergeist rspec

# Run with specific environment
ENV=staging rspec
```

### Parallel Execution

- Use parallel test execution for faster runs
- Use proper test isolation
- Use proper database cleanup
- Use proper result aggregation

## Error Handling

### Screenshot Capture

- Automatic screenshots on failure
- Screenshots saved to `spec/screenshots/`
- Screenshot cleanup after runs
- Proper screenshot naming

### Browser Logs

- Capture browser console errors
- Filter out expected errors
- Fail tests on unexpected errors
- Proper error reporting

## Performance Considerations

### Test Optimization

- Use proper wait strategies
- Minimize unnecessary page loads
- Use efficient selectors
- Use proper test isolation

### Database Optimization

- Use database transactions
- Use proper cleanup strategies
- Use efficient data creation
- Use proper indexing

## Important Notes & Gotchas

- Feature tests require a running application
- Use `data-test-id` attributes for reliable test selectors
- Tests should clean up after themselves
- Use proper wait strategies for async operations
- Use page objects for complex interactions
- Use shared examples for common patterns

## Code Review Checklist

- [ ] Page objects used for complex interactions
- [ ] Proper wait strategies implemented
- [ ] Tests clean up after themselves
- [ ] Shared examples used where appropriate
- [ ] Proper test selectors used
- [ ] Test data management is efficient
- [ ] Error handling is robust
- [ ] Performance considerations addressed

## Common Patterns

### Feature Test Structure

```ruby
RSpec.describe 'Feature Name', type: :feature do
  let(:user) { create_user }
  
  before do
    sign_in(user)
  end
  
  it 'performs the expected action' do
    # Test implementation using page objects
    home_page = HomePage.new
    home_page.load
    
    home_page.navigate_to_lists
    
    expect(page).to have_text('Lists')
  end
end
```

### Page Object Example

```ruby
class ListPage < SitePrism::Page
  set_url '/lists/{id}'
  
  element :list_name, '[data-test-id="list-name"]'
  element :add_item_button, '[data-test-id="add-item-button"]'
  element :item_input, '[data-test-id="item-input"]'
  
  sections :items, ItemSection, '[data-test-id="list-item"]'
  
  def add_item(name)
    add_item_button.click
    item_input.set(name)
    item_input.send_keys(:enter)
  end
  
  def has_item?(name)
    items.any? { |item| item.name.text == name }
  end
end

class ItemSection < SitePrism::Section
  element :name, '[data-test-id="item-name"]'
  element :edit_button, '[data-test-id="edit-item"]'
  element :delete_button, '[data-test-id="delete-item"]'
end
```

### Helper Methods

```ruby
module AuthenticationHelper
  def sign_in(user)
    visit '/users/sign_in'
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Sign In'
  end
  
  def sign_out
    click_link 'Sign Out'
  end
end
```

This document should be updated as the feature testing codebase evolves and new patterns emerge. 