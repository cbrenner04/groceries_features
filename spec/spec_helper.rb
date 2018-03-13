# frozen_string_literal: true

require 'rspec'
require 'capybara'
require 'capybara/rspec'
require 'capybara/poltergeist'
require 'capybara-screenshot/rspec'
require 'selenium-webdriver'
require 'site_prism'
require 'sequel'
require 'envyable'

Dir["#{File.expand_path(__dir__)}/support/**/*.rb"].each { |f| require f }

Envyable.load('config/env.yml', ENV['ENV'] || 'development')

# RSpec configuration options
RSpec.configure do |config|
  config.full_backtrace = false
  config.expect_with :rspec do |c|
    c.syntax = %i[should expect]
  end
  config.example_status_persistence_file_path = 'spec/examples.txt'
  config.run_all_when_everything_filtered = true
  config.profile_examples = 10
  config.include Helpers::AuthenticationHelper
  config.include Helpers::DataHelper
  config.include Helpers::WaitHelper
  config.before(:suite) do
    DB = Sequel.connect(ENV['DATABASE_URL'])
    TEST_RUN = Time.now.to_i
  end
  config.after(:suite) do
    Helpers::DataCleanUpHelper.new(DB).remove_test_data
  end
  config.append_after(:each) do |spec|
    Helpers::ResultsHelper.new(
      ENV['ENV'],
      ENV['RESULTS_USER'],
      ENV['RESULTS_PASSWORD'],
      ENV['RESULTS_URL'],
      spec,
      TEST_RUN
    ).create_results
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
# set `DRIVER=poltergeist` on the command line when you want to run headless
Capybara.default_driver = ENV['DRIVER'].nil? ? :selenium : ENV['DRIVER'].to_sym
unless ENV['DRIVER'] == 'poltergeist'
  Capybara.page.driver.browser.manage.window.resize_to(1280, 743)
end
Capybara.save_path = 'spec/screenshots/'
Capybara.app_host = ENV['HOST']

# capybara-screenshot configuration options
Capybara::Screenshot.register_filename_prefix_formatter(:rspec) do |example|
  example.description.tr(' ', '-').gsub(%r{^.*\/spec\/}, '')
end
Capybara::Screenshot.autosave_on_failure = true
Capybara::Screenshot.prune_strategy = :keep_last_run

SitePrism.configure do |config|
  config.use_implicit_waits = true
end
