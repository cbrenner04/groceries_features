# frozen_string_literal: true

require 'rspec'
require 'capybara'
require 'capybara/rspec'
require 'capybara/poltergeist'
require 'capybara-screenshot/rspec'
require 'selenium-webdriver'

# RSpec configuration options
RSpec.configure do |config|
  config.full_backtrace = false
  config.expect_with :rspec do |c|
    c.syntax = %i[should expect]
  end
  config.example_status_persistence_file_path = 'spec/examples.txt'
  config.run_all_when_everything_filtered = true
  config.profile_examples = 10
end

# Capybara configuration options
Capybara.configure do |config|
  config.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app, browser: :chrome)
  end
  config.register_driver :poltergeist do |app|
    options = { js: true, js_errors: false, window_size: [1280, 743] }
    Capybara::Poltergeist::Driver.new(app, options)
  end
  # set `driver=poltergeist` on the command line when you want to run headless
  config.default_driver = ENV['driver'].nil? ? :selenium : ENV['driver'].to_sym
  unless ENV['driver'] == 'poltergeist'
    config.page.driver.browser.manage.window.resize_to(1280, 743)
  end
  config.save_path = 'spec/screenshots/'
end

# capybara-screenshot configuration options
Capybara::Screenshot.register_filename_prefix_formatter(:rspec) do |example|
  example.description.tr(' ', '-').gsub(%r{^.*\/spec\/}, '')
end
Capybara::Screenshot.autosave_on_failure = true
Capybara::Screenshot.prune_strategy = :keep_last_run
