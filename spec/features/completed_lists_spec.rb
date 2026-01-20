# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Completed lists page", type: :feature do
  let(:home_page) { Pages::Home.new }
  let(:completed_lists_page) { Pages::CompletedLists.new }
  let(:share_list_page) { Pages::ShareList.new }
  let(:list_page) { Pages::List.new }
  let(:user) { Models::User.new }
  let(:template_name) { "grocery list template" }
  let(:other_user) { Models::User.new }
  let(:list) { Models::List.new(template_name: template_name, completed: true, owner_id: user.id) }
  let(:other_list) { Models::List.new(template_name: template_name, owner_id: other_user.id, completed: true) }

  before do
    @list_items = create_associated_list_objects(user, list)
    create_associated_list_objects(user, other_list)

    login user
    completed_lists_page.load

    wait_for { completed_lists_page.complete_list_names.include? list.name }
  end

  it "refreshes list" do
    completed_lists_page.refresh list.name

    completed_lists_names = completed_lists_page.complete_list_names

    expect(completed_lists_names).to include "#{list.name}*"
    expect(completed_lists_names.select { |name| name == list.name }).to be_empty

    home_page.load

    wait_for { home_page.incomplete_list_names.include? list.name }

    expect(home_page.incomplete_list_names).to include list.name

    home_page.select_list list.name

    wait_for { list_page.not_completed_items.any? }

    incomplete_items = @list_items.reject(&:completed)

    expect(list_page.not_completed_items.map(&:text)).to include incomplete_items.first.pretty_title
    expect(list_page.not_completed_items.map(&:text)).to include incomplete_items.last.pretty_title
  end

  it "deletes list" do
    completed_lists_page.delete list.name
    completed_lists_page.wait_until_confirm_delete_button_visible

    # for some reason if the button is clicked to early it doesn't work
    sleep 1

    completed_lists_page.confirm_delete_button.click

    wait_for { !completed_lists_page.complete_list_names.include?(list.name) }

    remaining_lists = completed_lists_page.complete_list_names_immediate
    expect(remaining_lists.select { |name| name == list.name }).to be_empty
  end

  describe "shared list" do
    it "is deleted" do
      completed_lists_page.delete other_list.name
      completed_lists_page.wait_until_confirm_delete_button_visible

      # for some reason if the button is clicked to early it doesn't work
      sleep 1

      completed_lists_page.confirm_delete_button.click

      wait_for { !completed_lists_page.complete_list_names.include?(other_list.name) }

      expect(completed_lists_page).to have_list_deleted_alert
      remaining_lists = completed_lists_page.complete_list_names_immediate
      expect(remaining_lists.select { |name| name == other_list.name }).to be_empty

      # users_list should be refused
      users_list = DB[:users_lists].where(user_id: user.id, list_id: other_list.id).first

      expect(users_list[:has_accepted]).to be false

      # list should still exist
      list = DB[:lists].where(id: other_list.id).first

      expect(list[:archived_at]).to be_nil
    end

    it "cannot be refreshed" do
      shared_list = completed_lists_page.find_complete_list(other_list.name)

      expect(shared_list.find(completed_lists_page.refresh_button_css)).to be_disabled
    end
  end
end
