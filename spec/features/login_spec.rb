# frozen_string_literal: true

require 'spec_helper'

RSpec.feature 'Login' do
  let(:home_page) { Pages::Home.new }
  let(:login_page) { Pages::Login.new }

  context 'when user exists' do
    let(:user) { Models::User.new }

    it 'is able to log in' do
      login user

      expect(home_page).to have_header
    end

    it 'is able to request reset password' do
      login_page.load
      login_page.forgot_password.click

      login_page.wait_for_log_in
      login_page.email.set user.email
      login_page.submit.click

      login_page.wait_for_password
      expect(login_page).to have_password
    end
  end

  context 'when user does not exist' do
    let(:user) { Models::User.new(create_user: false) }

    it 'is not able to log in' do
      login user, expect_success: false

      expect(home_page).to have_no_header
      expect(login_page).to have_password
    end

    it 'is not able to sign up' do
      login_page.load
      expect(login_page).to have_no_sign_up
    end

    it 'is redirected to sign in upon password reset request' do
      login_page.load
      login_page.forgot_password.click

      login_page.wait_for_log_in
      login_page.email.set user.email
      login_page.submit.click

      login_page.wait_for_password
      expect(login_page).to have_password
    end

    it 'is redirected to sign in when accessing other pages' do
      home_page.load

      expect(home_page).to have_no_header
      expect(login_page).to have_password
    end
  end
end
