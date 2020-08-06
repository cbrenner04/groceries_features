# frozen_string_literal: true

module Helpers
  # helpers for authenticating as a user
  module AuthenticationHelper
    def login(user, expect_success: true)
      login_page.load
      enter_email(user)
      login_page.password.set user.password
      login_page.submit.click
      return unless expect_success

      home_page.wait_until_log_out_visible
      expect(home_page).to have_log_out
    end

    def logout
      home_page.log_out.click
      login_page.wait_for_email
    end

    private

    def enter_email(user)
      login_page.email.set user.email
    rescue Capybara::ElementNotFound
      logout if home_page.has_header?
      logout if home_page.has_text? "You are already signed in"
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
