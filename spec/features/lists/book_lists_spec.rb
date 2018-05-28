# frozen_string_literal: true

require 'spec_helper'

RSpec.feature 'A book list' do
  let(:home_page) { Pages::Home.new }
  let(:edit_list_page) { Pages::EditList.new }
  let(:share_list_page) { Pages::ShareList.new }
  let(:list_page) { Pages::List.new }
  let(:user) { Models::User.new }
  let(:list_type) { 'BookList' }

  it 'is created' do
    list = Models::List.new(type: list_type, create_list: false)

    login user
    home_page.name.set list.name
    home_page.book_list.click
    home_page.submit.click

    home_page.wait_for_incomplete_lists
    expect(home_page.incomplete_list_names.map(&:text)).to include list.name
  end

  describe 'that is incomplete' do
    let(:list) { Models::List.new(type: list_type) }

    before do
      @list_items = create_associated_list_objects(user, list)

      login user
    end

    it 'is viewed' do
      home_page.select_list list.name
      list_page.wait_for_purchased_items

      expect(list_page.purchased_items.map(&:text))
        .to include @list_items.last.pretty_title
    end

    it 'is completed' do
      home_page.complete list.name

      home_page.wait_for_complete_lists
      expect(home_page.complete_list_names.map(&:text)).to include list.name
    end

    it 'is shared with a new user' do
      before_creation_user_count = DB[:users].count

      home_page.share list.name

      new_user_email = "share-new-user-test-#{Time.now.to_i}@example.com"
      share_list_page.email.set new_user_email
      share_list_page.submit.click

      home_page.wait_for_incomplete_lists
      expect(DB[:users].count).to eq before_creation_user_count + 1
      expect(DB[:users].where(email: new_user_email).count).to eq 1

      # for clean up purposes
      DB[:users].where(email: new_user_email).update(is_test_account: true)
    end

    it 'is shared with a previously shared with user' do
      other_user = Models::User.new
      other_list = Models::List.new(type: list_type)
      create_associated_list_objects(user, other_list)
      Models::UsersList.new(user_id: other_user.id, list_id: other_list.id)

      home_page.share list.name

      other_user_list_count_before_share = DB[:users_lists]
                                           .where(user_id: other_user.id)
                                           .count

      share_list_page.share_list_with other_user.email

      home_page.wait_for_incomplete_lists

      other_user_list_count_after_share = DB[:users_lists]
                                          .where(user_id: other_user.id)
                                          .count

      expect(other_user_list_count_after_share)
        .to eq other_user_list_count_before_share + 1

      other_user_lists = DB[:users_lists]
                         .where(user_id: other_user.id)
                         .map { |user_list| user_list[:list_id] }

      expect(other_user_lists).to include list.id
    end

    it 'is edited' do
      home_page.edit list.name

      list.name = SecureRandom.hex(16)

      wait_for do
        edit_list_page.name.set list.name
        edit_list_page.name.value == list.name
      end

      edit_list_page.submit.click

      home_page.wait_for_incomplete_lists
      expect(home_page.incomplete_list_names.map(&:text)).to include list.name
    end

    it 'is deleted' do
      home_page.accept_alert do
        home_page.delete list.name
      end

      home_page.wait_for_incomplete_lists
      home_page.wait_for_list_deleted_alert
      expect(home_page.incomplete_list_names.map(&:text))
        .to_not include list.name
    end
  end

  describe 'that is complete' do
    let(:list) { Models::List.new(type: list_type, completed: true) }

    before do
      @list_items = create_associated_list_objects(user, list)

      login user
    end

    it 'is viewed' do
      home_page.select_list list.name
      list_page.wait_for_purchased_items

      expect(list_page.purchased_items.map(&:text))
        .to include @list_items.last.pretty_title
    end

    it 'is refreshed' do
      home_page.refresh list.name

      home_page.wait_for_incomplete_lists
      expect(home_page.incomplete_list_names.map(&:text)).to include list.name

      home_page.select_list list.name
      list_page.wait_for_not_purchased_items

      expect(list_page.not_purchased_items.map(&:text))
        .to include @list_items.first.pretty_title
      expect(list_page.not_purchased_items.map(&:text))
        .to include @list_items.last.pretty_title
    end

    it 'is deleted' do
      home_page.accept_alert do
        home_page.delete list.name, complete: true
      end

      home_page.wait_for_incomplete_lists
      home_page.wait_for_complete_lists
      expect(home_page.complete_list_names.map(&:text)).to_not include list.name
    end
  end
end
