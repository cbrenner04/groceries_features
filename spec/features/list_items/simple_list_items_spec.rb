# frozen_string_literal: true

require "spec_helper"

RSpec.describe "A simple list item", type: :feature do
  let(:home_page) { Pages::Home.new }
  let(:list_page) { Pages::List.new }
  let(:edit_list_item_page) { Pages::EditListItem.new }
  let(:edit_list_items_page) { Pages::EditListItems.new }
  let(:user) { Models::User.new }
  let(:list) { Models::List.new(type: "SimpleList", owner_id: user.id) }

  def input_new_item_attributes(new_list_item)
    wait_for do
      list_page.content_input.set new_list_item.content
      list_page.content_input.value == new_list_item.content
    end
  end

  def bulk_updated_title(item)
    item.content
  end

  before do
    @list_items = create_associated_list_objects(user, list)
  end

  it_behaves_like "a list item", "content", "SimpleList", Models::SimpleListItem, []

  describe "when logged in as owner" do
    before do
      login user
      list_page.load(id: list.id)
      @initial_list_item_count = list_page.not_purchased_items.count
    end

    describe "that is completed" do
      it "is refreshed" do
        item_name = @list_items.last.pretty_title

        list_page.refresh item_name

        wait_for { list_page.not_purchased_items.count == @initial_list_item_count + 1 }

        list_page.filter_button.click
        list_page.filter_option("foo").click

        expect(list_page.not_purchased_items.map(&:text)).to include item_name
      end
    end

    describe "when multiple selected" do
      it "is refreshed" do
        list_page.multi_select_button.click
        @list_items.each { |item| list_page.multi_select_item(item.pretty_title, purchased: item.completed) }
        list_page.refresh(@list_items.last.pretty_title)

        wait_for { list_page.not_purchased_items.count == 0 }

        expect(list_page.purchased_items.count).to eq 0
        expect(list_page.not_purchased_items.count).to eq 3
      end
    end
  end

  describe "when logged in as shared user with write access" do
    before do
      write_user = Models::User.new
      Models::UsersList.new(user_id: write_user.id, list_id: list.id, has_accepted: true, permissions: "write")
      login write_user
      list_page.load(id: list.id)
    end

    it "can create, complete, edit, refresh, and destroy" do
      not_purchased_item = list_page.find_list_item(@list_items.first.content)
      purchased_item = list_page.find_list_item(@list_items.last.content, purchased: true)

      list_page.expand_list_item_form
      expect(list_page).to have_content_input
      expect(list_page).to have_submit_button
      expect(list_page).to have_multi_select_button
      expect(not_purchased_item).to have_css list_page.purchase_button_css
      expect(not_purchased_item).to have_css list_page.edit_button_css
      expect(not_purchased_item).to have_css list_page.delete_button_css
      expect(purchased_item).to have_css list_page.refresh_button_css
      expect(purchased_item).to have_css list_page.delete_button_css
    end
  end

  describe "when logged in as shared user with read access" do
    before do
      read_user = Models::User.new
      Models::UsersList.new(user_id: read_user.id, list_id: list.id, has_accepted: true, permissions: "read")
      login read_user
      list_page.load(id: list.id)
    end

    it "cannot create, complete, edit, refresh, or destroy" do
      not_purchased_item = list_page.find_list_item(@list_items.first.content)
      purchased_item = list_page.find_list_item(@list_items.last.content, purchased: true)

      expect(list_page).to have_no_content_input
      expect(list_page).to have_no_submit_button
      expect(list_page).to have_no_multi_select_button
      expect(not_purchased_item).to have_no_css list_page.purchase_button_css
      expect(not_purchased_item).to have_no_css list_page.edit_button_css
      expect(not_purchased_item).to have_no_css list_page.delete_button_css
      expect(purchased_item).to have_no_css list_page.refresh_button_css
      expect(purchased_item).to have_no_css list_page.delete_button_css
    end
  end
end
