# frozen_string_literal: true

require 'spec_helper'

RSpec.feature 'Completed lists page' do
  let(:home_page) { Pages::Home.new }
  let(:edit_list_page) { Pages::EditList.new }
  let(:share_list_page) { Pages::ShareList.new }
  let(:list_page) { Pages::List.new }
  let(:user) { Models::User.new }
  let(:list_type) { 'GroceryList' }
  let(:other_user) { Models::User.new }

  before do
    @list = Models::List.new(
      type: list_type,
      completed: true,
      owner_id: user.id
    )
    create_associated_list_objects(user, @list)
    @other_list = Models::List.new(
      type: list_type,
      owner_id: other_user.id,
      completed: true
    )
    create_associated_list_objects(user, @other_list)

    login user
  end

  it 'shows correct shit' do
    home_page.go_to_completed_lists
    owned_list = home_page.find_complete_list(@list.name)
    shared_list = home_page.find_complete_list(@other_list.name)

    expect(owned_list).to have_css home_page.refresh_button_css
    expect(owned_list).to have_css home_page.delete_button_css
    expect(shared_list).to have_no_css home_page.refresh_button_css
    expect(shared_list).to have_no_css home_page.delete_button_css
  end
end
