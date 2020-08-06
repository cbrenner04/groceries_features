# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Invite", type: :feature do
  let(:home_page) { Pages::Home.new }
  let(:share_list_page) { Pages::ShareList.new }
  let(:user) { Models::User.new }
  let(:pending_user) { Models::User.new }
  let(:accepted_user) { Models::User.new }
  let(:refused_user) { Models::User.new }

  before do
    login user
    list = Models::List.new(type: "GroceryList",
                            create_list: true, owner_id: user.id)
    create_associated_list_objects(user, list)
    Models::UsersList.new(user_id: pending_user.id, list_id: list.id,
                          has_accepted: nil, permissions: "write")
    Models::UsersList.new(user_id: accepted_user.id, list_id: list.id,
                          has_accepted: true, permissions: "read")
    Models::UsersList.new(user_id: refused_user.id, list_id: list.id,
                          has_accepted: false, permissions: "write")
    share_list_page.load(id: list.id)
  end

  it "shows correct users in correct buckets" do
    pending = share_list_page.find_shared_user(shared_state: "pending",
                                               user_id: pending_user.id)
    accepted = share_list_page.find_shared_user(shared_state: "accepted",
                                                user_id: accepted_user.id)
    refused = share_list_page.find_shared_user(shared_state: "refused",
                                               user_id: refused_user.id)

    expect(pending).to have_text pending_user.email
    expect(pending).to have_css share_list_page.write_badge_css
    expect(accepted).to have_text accepted_user.email
    expect(accepted).to have_css share_list_page.read_badge_css
    expect(refused).to have_text refused_user.email
    expect(refused).to have_no_css share_list_page.write_badge_css
    expect(refused).to have_no_css share_list_page.read_badge_css
  end

  it "toggles permissions" do
    pending = share_list_page.find_shared_user(shared_state: "pending",
                                               user_id: pending_user.id)

    expect(pending).to have_text pending_user.email
    expect(pending).to have_css share_list_page.write_badge_css

    share_list_page.toggle_permissions(shared_state: "pending",
                                       user_id: pending_user.id)

    pending = share_list_page.find_shared_user(shared_state: "pending",
                                               user_id: pending_user.id)

    expect(pending).to have_text pending_user.email
    expect(pending).to have_css share_list_page.read_badge_css
  end

  it "refreshes share" do
    refused = share_list_page.find_shared_user(shared_state: "refused",
                                               user_id: refused_user.id)

    expect(refused).to have_text refused_user.email
    expect(refused).to have_no_css share_list_page.write_badge_css
    expect(refused).to have_no_css share_list_page.read_badge_css

    share_list_page.refresh_share(user_id: refused_user.id)

    expect(share_list_page)
      .to have_no_selector("[data-test-id='accepted-user-#{refused_user.id}']")
    expect(share_list_page)
      .to have_no_selector("[data-test-id='pending-user-#{refused_user.id}']")
    expect(share_list_page)
      .to have_no_selector("[data-test-id='refused-user-#{refused_user.id}']")
  end

  it "removes share" do
    accepted = share_list_page.find_shared_user(shared_state: "accepted",
                                                user_id: accepted_user.id)

    expect(accepted).to have_text accepted_user.email
    expect(accepted).to have_css share_list_page.read_badge_css

    share_list_page.remove_share(shared_state: "accepted",
                                 user_id: accepted_user.id)

    expect(share_list_page)
      .to have_no_selector("[data-test-id='accepted-user-#{accepted_user.id}']")
    expect(share_list_page)
      .to have_no_selector("[data-test-id='pending-user-#{accepted_user.id}']")
    expect(share_list_page)
      .to have_no_selector("[data-test-id='refused-user-#{accepted_user.id}']")
  end
end
