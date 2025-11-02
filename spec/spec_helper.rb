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
require "byebug"
require "rspec/retry"

require_relative "support/pages/test_selectors"

Dir["#{File.expand_path(__dir__)}/support/**/*.rb"].each { |f| require f }

Envyable.load("config/env.yml", ENV["ENV"] || "development")

class DriverJSError < StandardError; end

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
      RESULTS_HELPER.sign_in
    end
  end
  # rubocop:enable Lint/ConstantDefinitionInBlock
  config.default_retry_count = 1
  config.after(type: :feature) do
    # TODO: CSP is throwing on something but doesn't effect the tests
    # This only matters in staging
    unless ENV["ENV"] == "staging"
      errors = page.driver.browser.logs.get(:browser).select do |e|
        e.level == "SEVERE" && !e.message.empty? && !e.message.include?("Unauthorized") &&
          !e.message.include?("Not Found") && !e.message.include?("Forbidden")
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

CONSTANT_WINDOW_SIZE = [1728, 960].freeze

# Capybara configuration options
Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end
Capybara.register_driver :poltergeist do |app|
  options = { js: true, js_errors: false, window_size: CONSTANT_WINDOW_SIZE }
  Capybara::Poltergeist::Driver.new(app, options)
end
# set `DRIVER=poltergeist` on the command line when you want to run headless
Capybara.default_driver = ENV["DRIVER"].nil? ? :selenium : ENV["DRIVER"].to_sym
unless ENV["DRIVER"] == "poltergeist"
  Capybara.javascript_driver = :chrome
  Capybara.page.driver.browser.manage.window.resize_to(*CONSTANT_WINDOW_SIZE)
end
Capybara.save_path = "spec/screenshots/"
Capybara.app_host = ENV.fetch("HOST", nil)
Capybara.default_max_wait_time = 3

# capybara-screenshot configuration options
Capybara::Screenshot.register_filename_prefix_formatter(:rspec) do |example|
  example.description.tr(" ", "-").gsub(%r{^.*/spec/}, "")
end
Capybara::Screenshot.autosave_on_failure = true
Capybara::Screenshot.prune_strategy = :keep_last_run
