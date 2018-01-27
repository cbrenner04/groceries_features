# frozen_string_literal: true

module Helpers
  # helpers for authenticating as a user
  module AuthenticationHelper
    def login(user, expect_success: true)
      login_page.load
      enter_email
      login_page.password.set user.password
      login_page.submit.click
      home_page.wait_for_header if expect_success
    end

    def logout
      home_page.log_out.click
      login_page.wait_for_email
    end

    private

    def enter_email
      login_page.email.set user.email
    rescue Capybara::ElementNotFound
      logout if page.has_text? 'You are already signed in'
      retry
    end

    def home_page
      @home_page ||= Pages::Home.new
    end

    def login_page
      @login_page ||= Pages::Login.new
    end
  end
end
