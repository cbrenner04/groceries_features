# frozen_string_literal: true

require 'spec_helper'

def create_associated_to_do_list_objects(user, list)
  Models::UsersList.new(user_id: user.id, list_id: list.id)
  Models::ToDoListItem.new(user_id: user.id, to_do_list_id: list.id)
  Models::ToDoListItem
    .new(user_id: user.id, to_do_list_id: list.id, completed: true)
end

RSpec.feature 'To Do Lists' do
  let(:home_page) { Pages::Home.new }
  let(:user) { Models::User.new }

  before { login user }

  it 'creates' do
    list = Models::List.new(type: 'ToDoList', create_list: false)

    home_page.name.set list.name
    home_page.to_do_list.click
    home_page.submit.click

    home_page.wait_for_incomplete_lists
    expect(home_page.incomplete_list_names.map(&:text)).to include list.name
  end

  it 'edits' do
    list = Models::List.new(type: 'ToDoList')
    create_associated_to_do_list_objects(user, list)

    home_page.load
    home_page.edit list.name

    list.name = SecureRandom.hex(16)

    home_page.name.set list.name
    home_page.submit.click

    home_page.wait_for_incomplete_lists
    expect(home_page.incomplete_list_names.map(&:text)).to include list.name
  end

  it 'completes' do
    list = Models::List.new(type: 'ToDoList')
    create_associated_to_do_list_objects(user, list)

    home_page.load
    home_page.complete list.name

    home_page.wait_for_complete_lists
    expect(home_page.complete_list_names.map(&:text)).to include list.name
  end

  it 'refreshes' do
    list = Models::List.new(type: 'ToDoList', completed: true)
    create_associated_to_do_list_objects(user, list)

    home_page.load
    home_page.refresh list.name

    home_page.wait_for_incomplete_lists
    expect(home_page.incomplete_list_names.map(&:text)).to include list.name
  end
end
