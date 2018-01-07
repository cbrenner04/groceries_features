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
  config.include Helpers::Authentication
  config.before(:suite) do
    DB = Sequel.connect(ENV['DATABASE_URL'])
  end
  config.after(:suite) do
    users = DB[:users].where(is_test_account: true)
    user_ids = users.map { |user| user[:id] }
    users_lists = DB[:users_lists].where(user_id: user_ids)
    list_ids = users_lists.map { |list| list[:list_id] }
    lists = DB[:lists].where(id: list_ids)
    tables = %i[book_list_items grocery_list_items music_list_items
                to_do_list_items]
    user_ids.each do |id|
      tables.each do |table|
        DB[table].where(user_id: id).delete
      end
    end
    users_lists.delete
    lists.delete
    users.delete
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
