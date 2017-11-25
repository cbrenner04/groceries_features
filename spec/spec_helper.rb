# frozen_string_literal: true

require 'rspec'
require 'capybara'
require 'capybara/rspec'
require 'capybara/poltergeist'
require 'capybara-screenshot/rspec'
require 'selenium-webdriver'
require 'site_prism'
require 'pg'

Dir["#{File.expand_path(__dir__)}/support/**/*.rb"].each { |f| require f }

# RSpec configuration options
RSpec.configure do |config|
  config.full_backtrace = false
  config.expect_with :rspec do |c|
    c.syntax = %i[should expect]
  end
  config.example_status_persistence_file_path = 'spec/examples.txt'
  config.run_all_when_everything_filtered = true
  config.profile_examples = 10
  config.include Helpers::Authentication
  config.before(:suite) { DB = PG.connect(dbname: 'Groceries_development') }
  config.after(:suite) do
    DB.exec("DELETE FROM users WHERE is_test_account = 'true'")
    DB.close
  end
end

# Capybara configuration options
Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end
Capybara.register_driver :poltergeist do |app|
  options = { js: true, js_errors: false, window_size: [1280, 743] }
  Capybara::Poltergeist::Driver.new(app, options)
end
# set `driver=poltergeist` on the command line when you want to run headless
Capybara.default_driver = ENV['driver'].nil? ? :selenium : ENV['driver'].to_sym
unless ENV['driver'] == 'poltergeist'
  Capybara.page.driver.browser.manage.window.resize_to(1280, 743)
end
Capybara.save_path = 'spec/screenshots/'
Capybara.app_host = 'localhost:3000'

# capybara-screenshot configuration options
Capybara::Screenshot.register_filename_prefix_formatter(:rspec) do |example|
  example.description.tr(' ', '-').gsub(%r{^.*\/spec\/}, '')
end
Capybara::Screenshot.autosave_on_failure = true
Capybara::Screenshot.prune_strategy = :keep_last_run
