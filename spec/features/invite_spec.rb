# frozen_string_literal: true

require 'spec_helper'

RSpec.feature 'Invite' do
  let(:home_page) { Pages::Home.new }
  let(:invite_page) { Pages::Invite.new }
  let(:user) { Models::User.new }

  before { login user }

  context 'when user with email address does not exist' do
    it 'invites a user' do
      before_creation_user_count = DB[:users].count

      # TODO: this does not currently work
      # expect(home_page).to have_signed_in_alert

      home_page.invite.click

      new_user_email = "invite-new-user-test-#{Time.now.to_i}@example.com"
      invite_page.email.set new_user_email
      invite_page.submit.click

      expect(home_page).to have_header

      # TODO: check flash alert message (should be the same for both contexts)

      expect(DB[:users].count).to eq before_creation_user_count + 1
      expect(DB[:users].where(email: new_user_email).count).to eq 1

      # for clean up purposes
      DB[:users].where(email: new_user_email).update(is_test_account: true)
    end
  end

  context 'when user with email does exist' do
    it 'does not create a user and redirects to home' do
      user = Models::User.new

      before_invite_user_count = DB[:users].count

      # TODO: this does not currently work
      # expect(home_page).to have_signed_in_alert

      home_page.invite.click
      invite_page.email.set user.email
      invite_page.submit.click

      expect(home_page).to have_header

      # TODO: check flash alert message (should be the same for both contexts)

      expect(DB[:users].count).to eq before_invite_user_count
      expect(DB[:users].where(email: user.email).count).to eq 1

      # for clean up purposes
      DB[:users].where(email: user.email).update(is_test_account: true)
    end
  end
end
