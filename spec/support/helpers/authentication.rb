# frozen_string_literal: true

module Helpers
  # helpers for authenticating as a user
  module Authentication
    def login(user)
      login_page.load
      login_page.email.set user.email
      login_page.password.set user.password
      login_page.submit.click
      home_page.wait_for_header
    end

    private

    def login_page
      @login_page ||= Pages::Login.new
    end

    def home_page
      @home_page ||= Pages::Home.new
    end
  end
end
