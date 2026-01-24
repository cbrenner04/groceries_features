# frozen_string_literal: true

require "spec_helper"

RSpec.describe "A book list item", type: :feature do
  let(:home_page) { Pages::Home.new }
  let(:list_page) { Pages::List.new }
  let(:edit_list_item_page) { Pages::EditListItem.new }
  let(:edit_list_items_page) { Pages::EditListItems.new }
  let(:change_other_list_modal) { Pages::ChangeOtherListModal.new }
  let(:user) { Models::User.new }
  let(:list) { Models::List.new(template_name: "book list template", owner_id: user.id) }

  def input_new_item_attributes(new_list_item)
    list_page.author_input.set new_list_item.author
    list_page.title_input.set new_list_item.title
    list_page.number_in_series_input.set new_list_item.number_in_series

    expect(list_page.author_input.value).to eq new_list_item.author
    expect(list_page.title_input.value).to eq new_list_item.title
    expect(list_page.number_in_series_input.value).to eq new_list_item.number_in_series.to_s # input value is a string
  end

  def confirm_form_cleared
    expect(list_page.author_input.value).to eq ""
    expect(list_page.title_input.value).to eq ""
    expect(list_page.category_input.value).to eq ""
    expect(list_page.number_in_series_input.value).to eq ""
    expect(list_page.completed_checkbox).not_to be_checked
  end

  def bulk_updated_title(item)
    "foobar #{item.title} #{item.number_in_series} read: #{item.read}"
  end

  before { @list_items = create_associated_list_objects(user, list) }

  it_behaves_like "a list item", "title", "book list template", Models::BookListItem, ["author"]

  describe "when logged in as shared user with write access" do
    before do
      write_user = Models::User.new
      Models::UsersList.new(user_id: write_user.id, list_id: list.id, has_accepted: true, permissions: "write")
      login write_user
      list_page.load(id: list.id)
    end

    it "can create, complete, edit, and destroy" do
      not_completed_item = list_page.find_list_item(@list_items.first.title)
      completed_item = list_page.find_list_item(@list_items.last.title, completed: true)

      list_page.expand_list_item_form

      expect(list_page).to have_author_input
      expect(list_page).to have_title_input
      expect(list_page).to have_submit_button
      expect(list_page).to have_multi_select_buttons
      expect(not_completed_item).to have_css list_page.complete_button_css
      expect(not_completed_item).to have_css list_page.edit_button_css
      expect(not_completed_item).to have_css list_page.delete_button_css
      expect(completed_item).to have_css list_page.delete_button_css
    end
  end

  describe "when logged in as shared user with read access" do
    before do
      read_user = Models::User.new
      Models::UsersList.new(user_id: read_user.id, list_id: list.id, has_accepted: true, permissions: "read")
      login read_user
      list_page.load(id: list.id)
    end

    it "cannot create, complete, edit, or destroy" do
      not_completed_item = list_page.find_list_item(@list_items.first.title)
      completed_item = list_page.find_list_item(@list_items.last.title, completed: true)

      expect(list_page).to have_no_author_input
      expect(list_page).to have_no_title_input
      expect(list_page).to have_no_submit_button
      expect(list_page).to have_no_multi_select_buttons
      expect(not_completed_item).to have_no_css list_page.complete_button_css
      expect(not_completed_item).to have_no_css list_page.edit_button_css
      expect(not_completed_item).to have_no_css list_page.delete_button_css
      expect(completed_item).to have_no_css list_page.delete_button_css
    end
  end
end
