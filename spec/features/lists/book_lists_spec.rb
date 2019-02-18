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
    list =
      Models::List.new(type: list_type, create_list: false, owner_id: user.id)

    login user
    home_page.name.set list.name
    home_page.list_type.select 'books'
    home_page.submit.click

    home_page.wait_for_incomplete_lists
    expect(home_page.incomplete_list_names.map(&:text)).to include list.name
  end

  describe 'that is incomplete' do
    let(:list) { Models::List.new(type: list_type, owner_id: user.id) }

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
      other_list = Models::List.new(type: list_type, owner_id: other_user.id)
      create_associated_list_objects(user, other_list)
      Models::UsersList.new(user_id: other_user.id, list_id: other_list.id)

      home_page.share list.name

      other_user_list_count_before_share = DB[:users_lists]
                                           .where(user_id: other_user.id)
                                           .count

      share_list_page.share_list_with other_user.id

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

    describe 'that is shared' do
      describe 'with write access' do
        it 'can be edited, completed or deleted' do
          expect(home_page).to have_complete_button
          expect(home_page).to have_delete_button
          expect(home_page).to have_edit_button
        end

        it 'is updated to change sharee permissions' do
          other_user = Models::User.new
          create_associated_list_objects(other_user, list)

          home_page.share list.name

          share_list_page.toggle_permissions(user_id: other_user.id)

          expect(share_list_page).to have_read_badge

          share_list_page.toggle_permissions(user_id: other_user.id)

          expect(share_list_page).to have_write_badge
        end
      end

      describe 'with read access' do
        before do
          DB[:users_lists]
            .where(user_id: user.id, list_id: list.id)
            .update(permissions: 'read')
        end

        it 'cannot be edited, completed or deleted' do
          home_page.load
          sleep 3
          expect(home_page).to have_no_complete_button
          expect(home_page).to have_no_delete_button
          expect(home_page).to have_no_edit_button
        end

        it 'cannot be updated to change sharee permissions' do
          other_user = Models::User.new
          create_associated_list_objects(other_user, list)

          home_page.share list.name
          share_list_page.wait_for_email

          expect(share_list_page).to have_no_write_badge
        end
      end
    end
  end

  describe 'that is complete' do
    let(:list) do
      Models::List.new(type: list_type, completed: true, owner_id: user.id)
    end

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

    describe 'that is shared' do
      describe 'with write access' do
        it 'can be refreshed or deleted' do
          expect(home_page).to have_refresh_button
          expect(home_page).to have_delete_button
        end
      end

      describe 'with only read access' do
        before do
          DB[:users_lists]
            .where(user_id: user.id, list_id: list.id)
            .update(permissions: 'read')
        end

        it 'cannot be refreshed or deleted' do
          expect(home_page).to have_no_refresh_button
          expect(home_page).to have_no_delete_button
        end
      end
    end
  end
end
