# frozen_string_literal: true

module Helpers
  # helpers for authenticating as a user
  module AuthenticationHelper
    # rubocop:disable AbcSize
    def login(user, expect_success: true)
      login_page.load
      login_page.email.set user.email
      login_page.password.set user.password
      login_page.submit.click
      home_page.wait_for_header if expect_success
    end
    # rubocop:enable AbcSize

    private

    def home_page
      @home_page ||= Pages::Home.new
    end

    def login_page
      @login_page ||= Pages::Login.new
    end
  end
end
