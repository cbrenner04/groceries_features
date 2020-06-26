# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'A book list item', type: :feature do
  let(:list_page) { Pages::List.new }
  let(:edit_list_item_page) { Pages::EditListItem.new }
  let(:user) { Models::User.new }
  let(:list) { Models::List.new(type: 'BookList', owner_id: user.id) }

  before do
    @list_items = create_associated_list_objects(user, list)
  end

  describe 'when logged in as owner' do
    before do
      login user
      list_page.load(id: list.id)
      @initial_list_item_count = list_page.not_purchased_items.count
    end

    it 'is created' do
      new_list_item = Models::BookListItem.new(user_id: user.id,
                                               book_list_id: list.id,
                                               create_item: false,
                                               category: 'foo')

      list_page.author_input.set new_list_item.author
      list_page.title_input.set new_list_item.title
      list_page.number_in_series_input.set new_list_item.number_in_series
      list_page.category_input.set new_list_item.category
      list_page.submit_button.click

      wait_for do
        list_page.not_purchased_items.count == @initial_list_item_count + 1
      end

      expect(list_page.not_purchased_items.map(&:text))
        .to include new_list_item.pretty_title
      expect(list_page.category_header.text)
        .to eq new_list_item.category.capitalize
    end

    describe 'that is not purchased' do
      it 'is read' do
        item_name = @list_items.first.pretty_title

        list_page.read item_name

        expect(list_page).to have_read_item item_name
      end

      it 'is purchased' do
        item_name = @list_items.first.pretty_title

        list_page.purchase item_name

        wait_for do
          list_page.purchased_items.count == @initial_list_item_count + 1
        end

        expect(list_page.purchased_items.map(&:text)).to include item_name
      end

      it 'is edited' do
        item = @list_items.first

        list_page.edit item.pretty_title

        item.title = SecureRandom.hex(16)

        wait_for do
          edit_list_item_page.title.set item.title
          edit_list_item_page.title.value == item.title
        end

        edit_list_item_page.submit.click

        expect(list_page.not_purchased_items.map(&:text))
          .to include item.pretty_title
      end

      it 'is destroyed' do
        item_name = @list_items.first.pretty_title

        list_page.delete item_name
        list_page.wait_until_confirm_delete_button_visible

        # for some reason if the button is clicked to early it doesn't work
        sleep 1

        list_page.confirm_delete_button.click

        wait_for do
          list_page.not_purchased_items.count == @initial_list_item_count - 1
        end

        expect(list_page.not_purchased_items.count)
          .to eq @initial_list_item_count - 1
        expect(list_page).to have_item_deleted_alert
        expect(list_page.not_purchased_items.map(&:text))
          .not_to include item_name
      end

      describe 'when a filter is applied' do
        before do
          list_page.wait_until_purchased_items_visible
          list_page.filter_button.click
          list_page.filter_option('foo').click
        end

        it 'is read' do
          item_name = @list_items.first.pretty_title

          list_page.read item_name

          expect(list_page).to have_read_item item_name
        end

        it 'is edited' do
          item = @list_items.first

          list_page.edit item.pretty_title

          item.title = SecureRandom.hex(16)

          wait_for do
            edit_list_item_page.title.set item.title
            edit_list_item_page.title.value == item.title
          end

          edit_list_item_page.submit.click
          list_page.wait_until_not_purchased_items_visible
          list_page.filter_button.click
          list_page.filter_option('foo').click

          expect(list_page.not_purchased_items.map(&:text))
            .to include item.pretty_title
        end

        describe 'when there is only one item for the selected category' do
          it 'is purchased' do
            item_name = @list_items.first.pretty_title

            list_page.purchase item_name

            wait_for do
              list_page.purchased_items.count == @initial_list_item_count + 1
            end

            expect(list_page.purchased_items.map(&:text)).to include item_name
            # no longer filtered
            expect(list_page.not_purchased_items.map(&:text))
              .to include @list_items[1].pretty_title
          end

          it 'is destroyed' do
            item_name = @list_items.first.pretty_title

            list_page.delete item_name
            list_page.wait_until_confirm_delete_button_visible

            # for some reason if the button is clicked to early it doesn't work
            sleep 1

            list_page.confirm_delete_button.click

            wait_for do
              list_page.not_purchased_items.count ==
                @initial_list_item_count - 1
            end

            expect(list_page.not_purchased_items.count)
              .to eq @initial_list_item_count - 1
            expect(list_page).to have_item_deleted_alert
            expect(list_page.not_purchased_items.map(&:text))
              .not_to include item_name
            # no longer filtered
            expect(list_page.not_purchased_items.map(&:text))
              .to include @list_items[1].pretty_title
          end
        end

        describe 'when there are multiple items for the selected category' do
          before do
            @another_list_item =
              Models::BookListItem
              .new(user_id: user.id, book_list_id: list.id, category: 'foo')
            @initial_list_item_count += 1
            # need to wait for the item to be added
            # TODO: do something better
            sleep 1
            # due to adding data above we need to reload page and filter again
            list_page.load(id: list.id)
            list_page.wait_until_purchased_items_visible
            list_page.filter_button.click
            list_page.filter_option('foo').click
          end

          it 'is purchased' do
            item_name = @list_items.first.pretty_title

            list_page.purchase item_name

            wait_for do
              list_page.purchased_items.count == @initial_list_item_count + 1
            end

            not_purchased_list_items = list_page.not_purchased_items.map(&:text)

            expect(list_page.purchased_items.map(&:text)).to include item_name
            expect(not_purchased_list_items)
              .to include @another_list_item.pretty_title
            expect(not_purchased_list_items)
              .not_to include @list_items[1].pretty_title
          end

          it 'is destroyed' do
            initial_list_item_count = list_page.not_purchased_items.count
            item_name = @list_items.first.pretty_title

            list_page.delete item_name
            list_page.wait_until_confirm_delete_button_visible

            # for some reason if the button is clicked to early it doesn't work
            # TODO: do something better
            sleep 1

            list_page.confirm_delete_button.click

            wait_for do
              list_page.not_purchased_items.count ==
                initial_list_item_count - 1
            end

            expect(list_page.not_purchased_items.count)
              .to eq initial_list_item_count - 1
            expect(list_page).to have_item_deleted_alert
            expect(list_page.not_purchased_items.map(&:text))
              .not_to include item_name
            expect(list_page.not_purchased_items.map(&:text))
              .to include @another_list_item.pretty_title
            expect(list_page.not_purchased_items.map(&:text))
              .not_to include @list_items[1].pretty_title
          end
        end
      end
    end

    describe 'that is purchased' do
      it 'is read' do
        item_name = @list_items.last.pretty_title

        list_page.read item_name, purchased: true

        expect(list_page).to have_read_item item_name, purchased: true
      end

      it 'is destroyed' do
        initial_purchase_items_count = list_page.purchased_items.count
        item_name = @list_items.last.pretty_title

        list_page.delete item_name, purchased: true
        list_page.wait_until_confirm_delete_button_visible

        # for some reason if the button is clicked to early it doesn't work
        sleep 1

        list_page.confirm_delete_button.click

        wait_for do
          list_page.purchased_items.count == initial_purchase_items_count - 1
        end

        expect(list_page.purchased_items.map(&:text)).not_to include item_name
      end
    end
  end

  describe 'when logged in as shared user with write access' do
    before do
      write_user = Models::User.new
      Models::UsersList.new(user_id: write_user.id, list_id: list.id,
                            has_accepted: true, permissions: 'write')
      login write_user
      list_page.load(id: list.id)
    end

    it 'can create, read, purchase, edit, and destroy' do
      not_purchased_item = list_page.find_list_item(@list_items.first.title)
      purchased_item = list_page.find_list_item(@list_items.last.title,
                                                purchased: true)

      expect(list_page).to have_author_input
      expect(list_page).to have_title_input
      expect(list_page).to have_submit_button
      expect(not_purchased_item).to have_css list_page.unread_button_css
      expect(not_purchased_item).to have_css list_page.purchase_button_css
      expect(not_purchased_item).to have_css list_page.edit_button_css
      expect(not_purchased_item).to have_css list_page.delete_button_css
      expect(purchased_item).to have_css list_page.unread_button_css
      expect(purchased_item).to have_css list_page.delete_button_css
    end
  end

  describe 'when logged in as shared user with read access' do
    before do
      read_user = Models::User.new
      Models::UsersList.new(user_id: read_user.id, list_id: list.id,
                            has_accepted: true, permissions: 'read')
      login read_user
      list_page.load(id: list.id)
    end

    it 'cannot create, read, purchase, edit, or destroy' do
      not_purchased_item = list_page.find_list_item(@list_items.first.title)
      purchased_item = list_page.find_list_item(@list_items.last.title,
                                                purchased: true)

      expect(list_page).to have_no_author_input
      expect(list_page).to have_no_title_input
      expect(list_page).to have_no_submit_button
      expect(not_purchased_item).to have_no_css list_page.unread_button_css
      expect(not_purchased_item).to have_no_css list_page.purchase_button_css
      expect(not_purchased_item).to have_no_css list_page.edit_button_css
      expect(not_purchased_item).to have_no_css list_page.delete_button_css
      expect(purchased_item).to have_no_css list_page.unread_button_css
      expect(purchased_item).to have_no_css list_page.delete_button_css
    end
  end
end
