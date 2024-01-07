# frozen_string_literal: true

require "rspec"
require "capybara"
require "capybara/rspec"
require "capybara/poltergeist"
require "capybara-screenshot/rspec"
require "selenium-webdriver"
require "site_prism"
require "sequel"
require "envyable"
require "webdrivers/chromedriver"
require "byebug"
require "rspec/retry"

Dir["#{File.expand_path(__dir__)}/support/**/*.rb"].sort.each { |f| require f }

Envyable.load("config/env.yml", ENV["ENV"] || "development")

class DriverJSError < StandardError; end

# seems like latest chrome is not covered yet. revisit and remove
Webdrivers::Chromedriver.required_version = '114.0.5735.90'

# RSpec configuration options
RSpec.configure do |config|
  config.full_backtrace = false
  config.expect_with :rspec do |c|
    c.syntax = %i[should expect]
  end
  config.example_status_persistence_file_path = "spec/tmp/examples.txt"
  config.run_all_when_everything_filtered = true
  config.profile_examples = 10
  config.include Helpers::AuthenticationHelper
  config.include Helpers::DataHelper
  config.include Helpers::WaitHelper
  # rubocop:disable Lint/ConstantDefinitionInBlock
  config.before(:suite) do
    DB = Sequel.connect(ENV.fetch("DATABASE_URL", nil))
    TEST_RUN = Time.now.to_i
    unless ENV["PARALLELS"]
      RESULTS_HELPER = Helpers::ResultsHelper.new
      RESULTS_HELPER.sign_in(ENV.fetch("RESULTS_USER", nil), ENV.fetch("RESULTS_PASSWORD", nil))
    end
  end
  # rubocop:enable Lint/ConstantDefinitionInBlock
  config.default_retry_count = 3
  config.after(type: :feature) do
    # TODO: chrome is being poopy atm with the datalist element in CategoryField
    # This only matters in staging
    unless ENV["ENV"] == "staging"
      errors = page.driver.browser.manage.logs.get(:browser).select do |e|
        e.level == "SEVERE" && !e.message.empty? && !e.message.include?("Unauthorized") &&
          !e.message.include?("Not Found")
      end.map(&:message)

      raise DriverJSError, errors.join("\n\n") if errors.any?
    end
  end
  config.append_after do |spec|
    # rubocop:disable Lint/OrAssignmentToConstant
    RESULTS_HELPER ||= Helpers::ResultsHelper.new
    RESULTS_HELPER.create_results(spec, TEST_RUN)
    # rubocop:enable Lint/OrAssignmentToConstant
  end
  config.after(:suite) do
    unless ENV["PARALLELS"]
      Helpers::DataCleanUpHelper.new(DB).remove_test_data
      RESULTS_HELPER.sign_out
    end
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
Capybara.default_driver = ENV["DRIVER"].nil? ? :selenium : ENV["DRIVER"].to_sym
unless ENV["DRIVER"] == "poltergeist"
  Capybara.javascript_driver = :chrome
  Capybara.page.driver.browser.manage.window.resize_to(1280, 743)
end
Capybara.save_path = "spec/screenshots/"
Capybara.app_host = ENV.fetch("HOST", nil)

# capybara-screenshot configuration options
Capybara::Screenshot.register_filename_prefix_formatter(:rspec) do |example|
  example.description.tr(" ", "-").gsub(%r{^.*/spec/}, "")
end
Capybara::Screenshot.autosave_on_failure = true
Capybara::Screenshot.prune_strategy = :keep_last_run
