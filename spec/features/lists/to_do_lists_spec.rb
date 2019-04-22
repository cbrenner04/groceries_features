# frozen_string_literal: true

require 'spec_helper'

RSpec.feature 'A to-do list' do
  let(:home_page) { Pages::Home.new }
  let(:edit_list_page) { Pages::EditList.new }
  let(:share_list_page) { Pages::ShareList.new }
  let(:list_page) { Pages::List.new }
  let(:user) { Models::User.new }
  let(:list_type) { 'ToDoList' }
  let(:other_user) { Models::User.new }
  let(:other_list) do
    Models::List.new(type: list_type, owner_id: other_user.id)
  end

  before { create_associated_list_objects(user, other_list) }

  it 'is created' do
    list =
      Models::List.new(type: list_type, create_list: false, owner_id: user.id)

    login user
    home_page.name.set list.name
    home_page.list_type.select 'to-do'
    home_page.submit.click

    home_page.wait_for_incomplete_lists
    wait_for do
      home_page.incomplete_list_names.map(&:text).include? list.name
    end

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
      share_list_page.wait_for_write_badge
      new_user_id = DB[:users].where(email: new_user_email).first[:id]
      shared_user_button =
        share_list_page
        .find_shared_user(shared_state: 'pending', user_id: new_user_id)

      expect(shared_user_button).to have_text new_user_email
      expect(DB[:users].count).to eq before_creation_user_count + 1
      expect(DB[:users].where(email: new_user_email).count).to eq 1

      # for clean up purposes
      DB[:users].where(email: new_user_email).update(is_test_account: true)
    end

    it 'is shared with a previously shared with user' do
      Models::UsersList.new(user_id: other_user.id, list_id: other_list.id)

      home_page.share list.name

      other_user_list_count_before_share = DB[:users_lists]
                                           .where(user_id: other_user.id)
                                           .count

      share_list_page.share_list_with other_user.id
      share_list_page.wait_for_write_badge
      shared_user_button =
        share_list_page
        .find_shared_user(shared_state: 'pending', user_id: other_user.id)

      expect(shared_user_button).to have_text other_user.email

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
      describe 'that is pending' do
        before do
          DB[:users_lists]
            .where(user_id: user.id, list_id: other_list.id)
            .update(permissions: 'read', has_accepted: nil)
          home_page.load
          home_page.wait_for_header
        end

        it 'can only accept or reject' do
          pending_list = home_page.find_pending_list(other_list.name)

          expect(pending_list).to have_no_link other_list.name

          expect(pending_list).to have_css home_page.complete_button_css
          expect(pending_list).to have_css home_page.delete_button_css
          expect(pending_list).to have_no_css home_page.share_button_css
          expect(pending_list).to have_no_css home_page.edit_button_css
        end

        it 'accepts' do
          home_page.accept other_list.name
          wait_for do
            home_page.incomplete_list_names.map(&:text).include? other_list.name
          end

          expect(home_page.incomplete_list_names.map(&:text))
            .to include other_list.name
        end

        it 'rejects' do
          home_page.accept_alert do
            home_page.reject other_list.name
          end

          home_page.wait_for_incomplete_lists

          expect(home_page.incomplete_list_names.map(&:text))
            .to_not include other_list.name
          expect(home_page.pending_list_names.map(&:text))
            .to_not include other_list.name
        end
      end

      describe 'that is accepted' do
        describe 'with write access' do
          before do
            DB[:users_lists]
              .where(user_id: user.id, list_id: other_list.id)
              .update(permissions: 'write')
            home_page.load
            home_page.wait_for_header
          end

          it 'can only be shared' do
            write_list = home_page.find_incomplete_list(other_list.name)

            expect(write_list).to have_css home_page.share_button_css
            expect(write_list).to have_no_css home_page.complete_button_css
            expect(write_list).to have_no_css home_page.delete_button_css
            expect(write_list).to have_no_css home_page.edit_button_css
          end

          it 'cannot update permissions' do
            create_associated_list_objects(other_user, other_list)

            home_page.share other_list.name

            list_user = share_list_page.find_shared_user(shared_state: 'accepted',
                                                        user_id: other_user.id)

            expect(list_user).to have_no_css share_list_page.write_badge_css
            expect(list_user).to have_no_css share_list_page.read_badge_css
          end
        end

        describe 'with read access' do
          before do
            DB[:users_lists]
              .where(user_id: user.id, list_id: other_list.id)
              .update(permissions: 'read')
            home_page.load
            home_page.wait_for_header
          end

          it 'cannot be edited, completed, shared, or deleted' do
            read_list = home_page.find_incomplete_list(other_list.name)

            expect(read_list).to have_no_css home_page.complete_button_css
            expect(read_list).to have_no_css home_page.delete_button_css
            expect(read_list).to have_no_css home_page.edit_button_css
            expect(read_list).to have_no_css home_page.share_button_css
          end
        end
      end

      describe 'that is refused' do
        before do
          DB[:users_lists]
            .where(user_id: user.id, list_id: other_list.id)
            .update(has_accepted: false)
          home_page.load
          home_page.wait_for_header
        end

        it 'should not be visible' do
          wait_for do
            !home_page.pending_list_names.map(&:text).include? other_list.name
          end

          expect(home_page.incomplete_list_names.map(&:text))
            .to_not include other_list.name
          expect(home_page.pending_list_names.map(&:text))
            .to_not include other_list.name
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
      home_page.wait_for_incomplete_lists
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
      wait_for do
        home_page.incomplete_list_names.map(&:text).include? list.name
      end

      expect(home_page.incomplete_list_names.map(&:text)).to include list.name

      home_page.select_list list.name
      list_page.wait_for_purchased_items

      expect(list_page.not_purchased_items.map(&:text))
        .to include @list_items.first.pretty_title
      expect(list_page.not_purchased_items.map(&:text))
        .to include @list_items.last.pretty_title
    end

    it 'is deleted' do
      wait_for { home_page.complete_list_names.map(&:text).include?(list.name) }

      home_page.accept_alert do
        home_page.delete list.name, complete: true
      end

      home_page.wait_for_incomplete_lists
      home_page.wait_for_complete_lists
      wait_for do
        !home_page.complete_list_names.map(&:text).include?(list.name)
      end

      expect(home_page.complete_list_names.map(&:text)).to_not include list.name
    end

    describe 'that is shared' do
      describe 'with write access' do
        before do
          DB[:users_lists]
            .where(user_id: user.id, list_id: other_list.id)
            .update(permissions: 'write')
          DB[:lists].where(id: other_list.id).update(completed: true)
          home_page.load
          home_page.wait_for_header
        end

        it 'cannot be refreshed or deleted' do
          wait_for do
            home_page.complete_list_names.map(&:text).include? other_list.name
          end

          write_list = home_page.find_complete_list(other_list.name)

          expect(write_list).to have_no_css home_page.refresh_button_css
          expect(write_list).to have_no_css home_page.delete_button_css
        end
      end

      describe 'with only read access' do
        before do
          DB[:users_lists]
            .where(user_id: user.id, list_id: other_list.id)
            .update(permissions: 'read')
          DB[:lists].where(id: other_list.id).update(completed: true)
          home_page.load
          home_page.wait_for_header
        end

        it 'cannot be refreshed or deleted' do
          read_list = home_page.find_complete_list(other_list.name)

          expect(read_list).to have_no_css home_page.refresh_button_css
          expect(read_list).to have_no_css home_page.delete_button_css
        end
      end
    end
  end
end
