# frozen_string_literal: true

require 'spec_helper'

RSpec.feature 'Login' do
  let(:home_page) { Pages::Home.new }
  let(:login_page) { Pages::Login.new }

  context 'when user exists' do
    let(:test_user) { Models::User.new }

    it 'is able to log in' do
      login test_user
      expect(home_page).to have_header
    end

    it 'is able to request reset password' do
      login_page.load
      login_page.forgot_password.click

      login_page.wait_for_log_in
      login_page.email.set test_user.email
      login_page.submit.click

      login_page.wait_for_password
      expect(login_page).to have_password
    end
  end

  context 'when user does not exist' do
    let(:fake_user) { Models::User.new(create: false) }

    it 'is not able to log in' do
      login fake_user, expect_success: false
      expect(home_page).to_not have_header
    end

    it 'is able to sign up' do
      login_page.load
      login_page.sign_up.click

      login_page.wait_for_log_in
      login_page.email.set fake_user.email
      login_page.password.set fake_user.password
      login_page.password_confirmation.set fake_user.password
      login_page.submit.click

      home_page.wait_for_header
      expect(home_page).to have_header
    end
  end
end
