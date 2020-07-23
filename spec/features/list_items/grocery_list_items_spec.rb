# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'A grocery list item', type: :feature do
  let(:home_page) { Pages::Home.new }
  let(:list_page) { Pages::List.new }
  let(:edit_list_item_page) { Pages::EditListItem.new }
  let(:edit_list_items_page) { Pages::EditListItems.new }
  let(:user) { Models::User.new }
  let(:list) { Models::List.new(type: 'GroceryList', owner_id: user.id) }

  before do
    @list_items = create_associated_list_objects(user, list)
  end

  describe 'when logged in as the list owner' do
    before do
      login user
      list_page.load(id: list.id)
      @initial_list_item_count = list_page.not_purchased_items.count
    end

    it 'is created' do
      new_list_item = Models::GroceryListItem.new(user_id: user.id,
                                                  grocery_list_id: list.id,
                                                  create_item: false,
                                                  category: 'foo')

      list_page.expand_list_item_form
      list_page.quantity_input.set new_list_item.quantity
      list_page.product_input.set new_list_item.product
      list_page.category_input.set new_list_item.category
      list_page.submit_button.click

      wait_for do
        list_page.not_purchased_items.count == @initial_list_item_count + 1
      end

      expect(list_page.not_purchased_items.map(&:text))
        .to include new_list_item.pretty_title
      category_headers = list_page.category_header.map(&:text)
      expect(category_headers.count).to eq 1
      expect(category_headers.first).to eq new_list_item.category.capitalize
    end

    describe 'that is not purchased' do
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

        item.product = SecureRandom.hex(16)

        wait_for do
          edit_list_item_page.product.set item.product
          edit_list_item_page.product.value == item.product
        end

        edit_list_item_page.submit.click
        list_page.wait_until_not_purchased_items_visible

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

        it 'is edited' do
          item = @list_items.first

          list_page.edit item.pretty_title

          item.product = SecureRandom.hex(16)

          wait_for do
            edit_list_item_page.product.set item.product
            edit_list_item_page.product.value == item.product
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
              Models::GroceryListItem
              .new(user_id: user.id, grocery_list_id: list.id, category: 'foo')
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

            expect(list_page.purchased_items.map(&:text)).to include item_name
            expect(list_page.not_purchased_items.map(&:text))
              .to include @another_list_item.pretty_title
            expect(list_page.not_purchased_items.map(&:text))
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
            # still filtered
            expect(list_page.not_purchased_items.map(&:text))
              .not_to include @list_items[1].pretty_title
          end
        end
      end
    end

    describe 'that is purchased' do
      it 'is refreshed' do
        item_name = @list_items.last.pretty_title

        list_page.refresh item_name

        wait_for do
          list_page.not_purchased_items.count == @initial_list_item_count + 1
        end

        list_page.filter_button.click
        list_page.filter_option('foo').click

        expect(list_page.not_purchased_items.map(&:text)).to include item_name
      end

      it 'is destroyed' do
        initial_purchased_items_count = list_page.purchased_items.count
        item_name = @list_items.last.pretty_title

        list_page.delete item_name, purchased: true
        list_page.wait_until_confirm_delete_button_visible

        # for some reason if the button is clicked to early it doesn't work
        sleep 1

        list_page.confirm_delete_button.click

        wait_for do
          list_page.purchased_items == initial_purchased_items_count - 1
        end

        expect(list_page.purchased_items.map(&:text)).not_to include item_name
      end
    end

    describe 'when multiple selected' do
      it 'is purchased' do
        list_page.multi_select_button.click
        @list_items.each do |item|
          list_page
            .multi_select_item(item.pretty_title, purchased: item.purchased)
        end
        list_page.purchase(@list_items.first.pretty_title)

        wait_for do
          list_page.not_purchased_items.count == 0
        end

        expect(list_page.not_purchased_items.count).to eq 0
        expect(list_page.purchased_items.count).to eq 3
      end

      it 'is refreshed' do
        list_page.multi_select_button.click
        @list_items.each do |item|
          list_page
            .multi_select_item(item.pretty_title, purchased: item.purchased)
        end
        list_page.refresh(@list_items.last.pretty_title)

        wait_for do
          list_page.not_purchased_items.count == 0
        end

        expect(list_page.purchased_items.count).to eq 0
        expect(list_page.not_purchased_items.count).to eq 3
      end

      it 'is destroyed' do
        list_page.multi_select_button.click
        @list_items.each do |item|
          list_page
            .multi_select_item(item.pretty_title, purchased: item.purchased)
        end
        list_page.delete(@list_items.first.pretty_title, purchased: false)
        list_page.wait_until_confirm_delete_button_visible

        # for some reason if the button is clicked too early it doesn't work
        sleep 1

        list_page.confirm_delete_button.click

        wait_for do
          list_page.not_purchased_items.count == 0
        end

        expect(list_page.not_purchased_items.count).to eq 0
        expect(list_page.purchased_items.count).to eq 0
      end

      describe 'when edited' do
        before do
          list_page.multi_select_button.click
          @list_items.each do |item|
            list_page
              .multi_select_item(item.pretty_title, purchased: item.purchased)
          end
          list_page.edit(@list_items.first.pretty_title)
        end

        it 'updates all attributes for items' do
          # change attributes to new attributes
          edit_list_items_page.quantity.set 'foobar'
          edit_list_items_page.category.set 'foobaz'
          edit_list_items_page.submit.click

          list_page.wait_until_not_purchased_items_visible

          # all items should now have the same category "foobaz"
          category_headers = list_page.category_header.map(&:text)
          expect(category_headers.count).to eq 1
          expect(category_headers[0]).to eq 'Foobaz'

          # all items should now have the same quantity "foobar"
          @list_items.each do |item|
            label = list_page
                    .find_list_item(item.product, purchased: item.purchased)
                    .text
            expect(label).to include "foobar #{item.product}"
          end

          # return to edit page for clearing below
          list_page.multi_select_button.click
          @list_items.each do |item|
            list_page.multi_select_item(
              "foobar #{item.product}", purchased: item.purchased
            )
          end
          list_page.edit("foobar #{@list_items.first.product}")

          # clear attributes
          edit_list_items_page.clear_quantity.click
          edit_list_items_page.clear_category.click
          edit_list_items_page.submit.click

          list_page.wait_until_not_purchased_items_visible

          # all items should have add their categories cleared
          expect(list_page.category_header.map(&:text).count).to eq 0

          # all items should have had their quantitys cleared
          @list_items.each do |item|
            label = list_page
                    .find_list_item(item.product, purchased: item.purchased)
                    .text
            expect(label).not_to include 'foobar'
          end
        end

        describe 'when copy' do
          it 'creates a new list' do
            edit_list_items_page.copy.click
            # cannot choose existing list when no other book lists exist
            all_link_text = edit_list_items_page.all_links.map(&:text)

            expect(all_link_text).not_to include 'Choose existing list'

            # create new list
            edit_list_items_page.new_list_name.set 'foobar'
            # updates current items
            edit_list_items_page.update_current_items.click
            edit_list_items_page.quantity.set 'foobar'
            edit_list_items_page.category.set 'foobaz'
            edit_list_items_page.submit.click

            list_page.wait_until_not_purchased_items_visible

            # all items should now have the same category "foobaz"
            category_headers = list_page.category_header.map(&:text)
            expect(category_headers.count).to eq 1
            expect(category_headers[0]).to eq 'Foobaz'

            # all items should now have the same quantity "foobar"
            @list_items.each do |item|
              label = list_page
                      .find_list_item(item.product, purchased: item.purchased)
                      .text
              expect(label).to include "foobar #{item.product}"
            end

            # check new list for new items
            home_page.load
            home_page.select_list 'foobar'
            list_page.wait_until_not_purchased_items_visible

            # all items should now have the same category "foobaz"
            new_list_category_headers = list_page.category_header.map(&:text)
            expect(new_list_category_headers.count).to eq 1
            expect(new_list_category_headers[0]).to eq 'Foobaz'

            # all items should now have the same quantity "foobar"
            # all items should be not purchased
            @list_items.each do |item|
              label =
                list_page.find_list_item(item.product, purchased: false).text
              expect(label).to include "foobar #{item.product}"
            end
          end

          it 'chooses existing list' do
            # create another list so option for existing list are available
            new_list = Models::List.new(type: 'GroceryList', owner_id: user.id)
            Models::UsersList.new(user_id: user.id, list_id: new_list.id)
            # select existing list
            edit_list_items_page.copy.click
            edit_list_items_page.existing_list.select new_list.name
            # does not update current items therefore these attributes will be
            # on the existing list but not the current list
            edit_list_items_page.quantity.set 'foobar'
            edit_list_items_page.category.set 'foobaz'
            edit_list_items_page.submit.click

            list_page.wait_until_not_purchased_items_visible

            # category should not have been updated
            category_headers = list_page.category_header.map(&:text)
            expect(category_headers.count).to eq 1
            expect(category_headers[0]).not_to eq 'Foobaz'

            # all items should have the same attributes
            @list_items.each do |item|
              label = list_page
                      .find_list_item(item.product, purchased: item.purchased)
                      .text
              expect(label).to include item.pretty_title
            end

            # go to existing list
            list_page.load(id: new_list.id)
            list_page.wait_until_not_purchased_items_visible

            # all items should now have the same category "foobaz"
            existing_list_category_headers =
              list_page.category_header.map(&:text)
            expect(existing_list_category_headers.count).to eq 1
            expect(existing_list_category_headers[0]).to eq 'Foobaz'

            # all items should now have the same quantity "foobar"
            # all items should be not purchased
            @list_items.each do |item|
              label = list_page
                      .find_list_item(item.product, purchased: false).text
              expect(label).to include "foobar #{item.product}"
            end
          end
        end

        describe 'when move' do
          it 'creates a new list' do
            edit_list_items_page.move.click
            # cannot choose existing list when no other book lists exist
            all_link_text = edit_list_items_page.all_links.map(&:text)

            expect(all_link_text).not_to include 'Choose existing list'

            # create new list
            edit_list_items_page.new_list_name.set 'foobar'

            # cannot update current items when moving
            expect(edit_list_items_page).to have_no_update_current_items

            edit_list_items_page.quantity.set 'foobar'
            edit_list_items_page.category.set 'foobaz'
            edit_list_items_page.submit.click

            # all items should have been moved
            expect(list_page).to have_no_not_purchased_items
            expect(list_page).to have_no_purchased_items

            # check new list for new items
            home_page.load
            home_page.select_list 'foobar'
            list_page.wait_until_not_purchased_items_visible

            # all items should now have the same category "foobaz"
            category_headers = list_page.category_header.map(&:text)
            expect(category_headers.count).to eq 1
            expect(category_headers[0]).to eq 'Foobaz'

            # all items should now have the same quantity "foobar"
            # all items should be not purchased
            @list_items.each do |item|
              label =
                list_page.find_list_item(item.product, purchased: false).text
              expect(label).to include "foobar #{item.product}"
            end
          end

          it 'chooses existing list' do
            # create another list so option for existing list are available
            new_list = Models::List.new(type: 'GroceryList', owner_id: user.id)
            Models::UsersList.new(user_id: user.id, list_id: new_list.id)
            # select existing list
            edit_list_items_page.move.click
            edit_list_items_page.existing_list.select new_list.name

            # cannot update current items when moving
            expect(edit_list_items_page).to have_no_update_current_items

            edit_list_items_page.quantity.set 'foobar'
            edit_list_items_page.category.set 'foobaz'
            edit_list_items_page.submit.click

            # all items should have been moved
            expect(list_page).to have_no_not_purchased_items
            expect(list_page).to have_no_purchased_items

            # go to existing list
            list_page.load(id: new_list.id)
            list_page.wait_until_not_purchased_items_visible

            # all items should now have the same category "foobaz"
            category_headers = list_page.category_header.map(&:text)
            expect(category_headers.count).to eq 1
            expect(category_headers[0]).to eq 'Foobaz'

            # all items should now have the same quantity "foobar"
            # all items should be not purchased
            @list_items.each do |item|
              label = list_page
                      .find_list_item(item.product, purchased: false).text
              expect(label).to include "foobar #{item.product}"
            end
          end
        end
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

    it 'can create, purchase, edit, refresh, and destroy' do
      not_purchased_item = list_page.find_list_item(@list_items.first.product)
      purchased_item = list_page.find_list_item(@list_items.last.product,
                                                purchased: true)

      list_page.expand_list_item_form

      expect(list_page).to have_quantity_input
      expect(list_page).to have_product_input
      expect(list_page).to have_submit_button
      expect(list_page).to have_multi_select_button
      expect(not_purchased_item).to have_css list_page.purchase_button_css
      expect(not_purchased_item).to have_css list_page.edit_button_css
      expect(not_purchased_item).to have_css list_page.delete_button_css
      expect(purchased_item).to have_css list_page.refresh_button_css
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

    it 'cannot create, purchase, edit, refresh, or destroy' do
      not_purchased_item = list_page.find_list_item(@list_items.first.product)
      purchased_item = list_page.find_list_item(@list_items.last.product,
                                                purchased: true)

      expect(list_page).to have_no_quantity_input
      expect(list_page).to have_no_product_input
      expect(list_page).to have_no_submit_button
      expect(list_page).to have_no_multi_select_button
      expect(not_purchased_item).to have_no_css list_page.purchase_button_css
      expect(not_purchased_item).to have_no_css list_page.edit_button_css
      expect(not_purchased_item).to have_no_css list_page.delete_button_css
      expect(purchased_item).to have_no_css list_page.refresh_button_css
      expect(purchased_item).to have_no_css list_page.delete_button_css
    end
  end
end
