# frozen_string_literal: true

require 'spec_helper'

RSpec.feature 'Invite' do
  let(:home_page) { Pages::Home.new }
  let(:invite_page) { Pages::Invite.new }
  let(:user) { Models::User.new }

  before { login user }

  it 'invites a user' do
    before_creation_user_count = DB[:users].count

    home_page.wait_for_signed_in_alert
    home_page.invite.click

    new_user_email = "invite-new-user-test-#{Time.now.to_i}@example.com"
    invite_page.email.set new_user_email
    invite_page.submit.click

    home_page.wait_for_incomplete_lists

    expect(home_page).to have_header
    expect(DB[:users].count).to eq before_creation_user_count + 1
    expect(DB[:users].where(email: new_user_email).count).to eq 1

    # for clean up purposes
    DB[:users].where(email: new_user_email).update(is_test_account: true)
  end
end
