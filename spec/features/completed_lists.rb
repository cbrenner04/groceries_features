# frozen_string_literal: true

require 'spec_helper'

RSpec.feature 'Completed lists page' do
  let(:home_page) { Pages::Home.new }
  let(:completed_lists_page) { Pages::CompletedLists.new }
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
    @list_items = create_associated_list_objects(user, @list)
    @other_list = Models::List.new(
      type: list_type,
      owner_id: other_user.id,
      completed: true
    )
    create_associated_list_objects(user, @other_list)

    login user
    home_page.go_to_completed_lists
  end

  it 'refreshes list' do
    completed_lists_page.refresh @list.name

    wait_for do
      home_page.incomplete_list_names.map(&:text).include? @list.name
    end

    expect(home_page.incomplete_list_names.map(&:text)).to include @list.name

    home_page.select_list @list.name

    expect(list_page).to have_not_purchased_items
    expect(list_page.not_purchased_items.map(&:text))
      .to include @list_items.first.pretty_title
    expect(list_page.not_purchased_items.map(&:text))
      .to include @list_items.last.pretty_title

  end

  it 'deletes list' do
    wait_for do
      completed_lists_page.complete_list_names.map(&:text).include? @list.name
    end

    home_page.accept_alert do
      home_page.delete @list.name, complete: true
    end

    wait_for do
      !home_page.complete_list_names.map(&:text).include?(@list.name)
    end

    expect(home_page.complete_list_names.map(&:text)).to_not include @list.name

  end


  describe 'shared list' do
    it 'does not show refresh or delete' do
      shared_list = completed_lists_page.find_complete_list(@other_list.name)

      expect(shared_list).to have_no_css completed_lists_page.refresh_button_css
      expect(shared_list).to have_no_css completed_lists_page.delete_button_css
    end
  end
end
