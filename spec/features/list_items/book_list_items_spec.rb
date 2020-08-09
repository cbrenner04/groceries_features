# frozen_string_literal: true

require "spec_helper"

RSpec.describe "A book list item", type: :feature do
  let(:home_page) { Pages::Home.new }
  let(:list_page) { Pages::List.new }
  let(:edit_list_item_page) { Pages::EditListItem.new }
  let(:edit_list_items_page) { Pages::EditListItems.new }
  let(:user) { Models::User.new }
  let(:list) { Models::List.new(type: "BookList", owner_id: user.id) }

  def input_new_item_attributes(new_list_item)
    list_page.author_input.set new_list_item.author
    list_page.title_input.set new_list_item.title
    list_page.number_in_series_input.set new_list_item.number_in_series
  end

  def bulk_updated_title(item)
    "\"#{item.title}\" foobar"
  end

  before { @list_items = create_associated_list_objects(user, list) }

  it_behaves_like "a list item", "title", "BookList", Models::BookListItem, ["author"]

  describe "when logged in as owner" do
    before do
      login user
      list_page.load(id: list.id)
      @initial_list_item_count = list_page.not_purchased_items.count
    end

    describe "that is not purchased" do
      it "is read" do
        item_name = @list_items.first.pretty_title

        list_page.read item_name

        expect(list_page).to have_read_item item_name
      end

      describe "when a filter is applied" do
        before do
          list_page.wait_until_purchased_items_visible
          list_page.filter_button.click
          list_page.filter_option("foo").click
        end

        it "is read" do
          item_name = @list_items.first.pretty_title

          list_page.read item_name

          expect(list_page).to have_read_item item_name
        end
      end
    end

    describe "that is purchased" do
      it "is read" do
        item_name = @list_items.last.pretty_title

        list_page.read item_name, purchased: true

        expect(list_page).to have_read_item item_name, purchased: true
      end
    end

    describe "when multiple selected" do
      it "is read" do
        list_page.multi_select_button.click
        @list_items.each { |item| list_page.multi_select_item(item.pretty_title, purchased: item.purchased) }
        list_page.read(@list_items.first.pretty_title, purchased: false)

        @list_items.each { |item| expect(list_page).to have_read_item item.pretty_title, purchased: item.purchased }
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

    it "can create, read, purchase, edit, and destroy" do
      not_purchased_item = list_page.find_list_item(@list_items.first.title)
      purchased_item = list_page.find_list_item(@list_items.last.title, purchased: true)

      list_page.expand_list_item_form

      expect(list_page).to have_author_input
      expect(list_page).to have_title_input
      expect(list_page).to have_submit_button
      expect(list_page).to have_multi_select_button
      expect(not_purchased_item).to have_css list_page.unread_button_css
      expect(not_purchased_item).to have_css list_page.purchase_button_css
      expect(not_purchased_item).to have_css list_page.edit_button_css
      expect(not_purchased_item).to have_css list_page.delete_button_css
      expect(purchased_item).to have_css list_page.unread_button_css
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

    it "cannot create, read, purchase, edit, or destroy" do
      not_purchased_item = list_page.find_list_item(@list_items.first.title)
      purchased_item = list_page.find_list_item(@list_items.last.title, purchased: true)

      expect(list_page).to have_no_author_input
      expect(list_page).to have_no_title_input
      expect(list_page).to have_no_submit_button
      expect(list_page).to have_no_multi_select_button
      expect(not_purchased_item).to have_no_css list_page.unread_button_css
      expect(not_purchased_item).to have_no_css list_page.purchase_button_css
      expect(not_purchased_item).to have_no_css list_page.edit_button_css
      expect(not_purchased_item).to have_no_css list_page.delete_button_css
      expect(purchased_item).to have_no_css list_page.unread_button_css
      expect(purchased_item).to have_no_css list_page.delete_button_css
    end
  end
end
