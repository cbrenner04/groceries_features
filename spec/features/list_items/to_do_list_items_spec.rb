# frozen_string_literal: true

require "spec_helper"

RSpec.describe "A to do list item", type: :feature do
  let(:home_page) { Pages::Home.new }
  let(:list_page) { Pages::List.new }
  let(:edit_list_item_page) { Pages::EditListItem.new }
  let(:edit_list_items_page) { Pages::EditListItems.new }
  let(:change_other_list_modal) { Pages::ChangeOtherListModal.new }
  let(:user) { Models::User.new }
  let(:list) { Models::List.new(type: "ToDoList", owner_id: user.id) }

  def input_new_item_attributes(new_list_item)
    list_page.task_input.set new_list_item.task
    fill_in "Due By", with: new_list_item.due_by.strftime("%m%d%Y")
  end

  def confirm_form_cleared
    expect(list_page.task_input.value).to eq ""
    expect(list_page.due_by_input.value).to eq ""
    expect(list_page.category_input.value).to eq ""
  end

  def bulk_updated_title(item)
    "#{item.task}\nAssigned To: #{user.email}\nDue By: February 2, 2020"
  end

  before do
    @list_items = create_associated_list_objects(user, list)
  end

  it_behaves_like "a list item", "task", "ToDoList", Models::ToDoListItem, %w[assignee due_by]
  it_behaves_like "a refreshable list item", "ToDoList"

  describe "when logged in as shared user with write access" do
    before do
      write_user = Models::User.new
      Models::UsersList.new(user_id: write_user.id, list_id: list.id, has_accepted: true, permissions: "write")
      login write_user
      list_page.load(id: list.id)
    end

    it "can create, complete, edit, refresh, and destroy" do
      not_purchased_item = list_page.find_list_item(@list_items.first.task)
      purchased_item = list_page.find_list_item(@list_items.last.task, purchased: true)

      list_page.expand_list_item_form
      expect(list_page).to have_task_input
      expect(list_page).to have_submit_button
      expect(list_page).to have_multi_select_buttons
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
      not_purchased_item = list_page.find_list_item(@list_items.first.task)
      purchased_item = list_page.find_list_item(@list_items.last.task, purchased: true)

      expect(list_page).to have_no_task_input
      expect(list_page).to have_no_submit_button
      expect(list_page).to have_no_multi_select_buttons
      expect(not_purchased_item).to have_no_css list_page.purchase_button_css
      expect(not_purchased_item).to have_no_css list_page.edit_button_css
      expect(not_purchased_item).to have_no_css list_page.delete_button_css
      expect(purchased_item).to have_no_css list_page.refresh_button_css
      expect(purchased_item).to have_no_css list_page.delete_button_css
    end
  end
end
