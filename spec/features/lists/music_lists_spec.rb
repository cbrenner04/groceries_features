# frozen_string_literal: true

require 'spec_helper'

RSpec.feature 'Music Lists' do
  let(:home_page) { Pages::Home.new }
  let(:edit_list_page) { Pages::EditList.new }
  let(:user) { Models::User.new }

  before { login user }

  it 'creates' do
    list = Models::List.new(type: 'MusicList', create_list: false)

    home_page.name.set list.name
    home_page.music_list.click
    home_page.submit.click

    home_page.wait_for_incomplete_lists
    expect(home_page.incomplete_list_names.map(&:text)).to include list.name
  end

  it 'edits' do
    list = Models::List.new(type: 'MusicList')
    create_associated_list_objects(user, list)

    home_page.load
    home_page.edit list.name

    list.name = SecureRandom.hex(16)

    # TODO: need to find a better solution
    # In production, the name input text not clearing before new name is entered
    # Therefore the old and new name are being concatenated upon submission
    # This results in a false negative
    edit_list_page.loaded?
    edit_list_page.name.set ''
    # TODO: end

    edit_list_page.name.set list.name
    edit_list_page.submit.click

    home_page.wait_for_incomplete_lists
    expect(home_page.incomplete_list_names.map(&:text)).to include list.name
  end

  it 'completes' do
    list = Models::List.new(type: 'MusicList')
    create_associated_list_objects(user, list)

    home_page.load
    home_page.complete list.name

    home_page.wait_for_complete_lists
    expect(home_page.complete_list_names.map(&:text)).to include list.name
  end

  it 'refreshes' do
    list = Models::List.new(type: 'MusicList', completed: true)
    create_associated_list_objects(user, list)

    home_page.load
    home_page.refresh list.name

    home_page.wait_for_incomplete_lists
    expect(home_page.incomplete_list_names.map(&:text)).to include list.name
  end
end
