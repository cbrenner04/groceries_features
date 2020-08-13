# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Completed lists page", type: :feature do
  let(:home_page) { Pages::Home.new }
  let(:completed_lists_page) { Pages::CompletedLists.new }
  let(:edit_list_page) { Pages::EditList.new }
  let(:share_list_page) { Pages::ShareList.new }
  let(:list_page) { Pages::List.new }
  let(:user) { Models::User.new }
  let(:list_type) { "GroceryList" }
  let(:other_user) { Models::User.new }
  let(:list) { Models::List.new(type: list_type, completed: true, owner_id: user.id) }
  let(:other_list) { Models::List.new(type: list_type, owner_id: other_user.id, completed: true) }

  before do
    @list_items = create_associated_list_objects(user, list)
    create_associated_list_objects(user, other_list)

    login user
    completed_lists_page.load

    wait_for { completed_lists_page.complete_list_names.map(&:text).include? list.name }
  end

  it "refreshes list" do
    completed_lists_page.refresh list.name

    completed_lists_names = completed_lists_page.complete_list_names.map(&:text)

    expect(completed_lists_names).to include "#{list.name}*"
    expect(completed_lists_names).not_to include list.name

    home_page.load

    wait_for { home_page.incomplete_list_names.map(&:text).include? list.name }

    expect(home_page.incomplete_list_names.map(&:text)).to include list.name

    home_page.select_list list.name

    expect(list_page).to have_not_purchased_items
    expect(list_page.not_purchased_items.map(&:text)).to include @list_items.first.pretty_title
    expect(list_page.not_purchased_items.map(&:text)).to include @list_items.last.pretty_title
  end

  it "deletes list" do
    completed_lists_page.delete list.name
    completed_lists_page.wait_until_confirm_delete_button_visible

    # for some reason if the button is clicked to early it doesn't work
    sleep 1

    completed_lists_page.confirm_delete_button.click

    wait_for { !completed_lists_page.complete_list_names.map(&:text).include?(list.name) }

    expect(completed_lists_page.complete_list_names.map(&:text)).not_to include list.name
  end

  describe "shared list" do
    it "is removed" do
      completed_lists_page.delete other_list.name
      completed_lists_page.wait_until_confirm_remove_button_visible

      # for some reason if the button is clicked to early it doesn't work
      sleep 1

      completed_lists_page.confirm_remove_button.click

      wait_for { !completed_lists_page.complete_list_names.map(&:text).include?(other_list.name) }

      expect(completed_lists_page).to have_list_removed_alert
      expect(completed_lists_page.complete_list_names.map(&:text)).not_to include other_list.name

      # users_list should be refused
      users_list = DB[:users_lists].where(user_id: user.id, list_id: other_list.id).first

      expect(users_list[:has_accepted]).to eq false

      # list should still exist
      list = DB[:lists].where(id: other_list.id).first

      expect(list[:archived_at]).to eq nil
    end

    it "cannot be refreshed" do
      shared_list = completed_lists_page.find_complete_list(other_list.name)

      expect(shared_list.find(completed_lists_page.refresh_button_css)).to be_disabled
    end
  end
end
