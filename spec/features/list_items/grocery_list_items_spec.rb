# frozen_string_literal: true

require 'spec_helper'

RSpec.feature 'A grocery list item' do
  let(:list_page) { Pages::List.new }
  let(:edit_list_item_page) { Pages::EditListItem.new }
  let(:user) { Models::User.new }
  let(:list) { Models::List.new(type: 'GroceryList', owner_id: user.id) }

  before do
    @list_items = create_associated_list_objects(user, list)
  end

  describe 'when logged in as the list owner' do
    before do
      login user
      list_page.load(id: list.id)
    end

    it 'is created' do
      new_list_item = Models::GroceryListItem.new(user_id: user.id,
                                                  grocery_list_id: list.id,
                                                  create_item: false)

      list_page.quantity_input.set new_list_item.quantity
      list_page.product_input.set new_list_item.product
      list_page.submit_button.click

      wait_for do
        list_page.not_purchased_items.count == 2
      end

      expect(list_page.not_purchased_items.map(&:text))
        .to include new_list_item.pretty_title
    end

    describe 'that is not purchased' do
      it 'is purchased' do
        item_name = @list_items.first.pretty_title

        list_page.purchase item_name

        wait_for do
          list_page.purchased_items.count == 2
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

        list_page.wait_for_not_purchased_items
        expect(list_page.not_purchased_items.map(&:text))
          .to include item.pretty_title
      end

      it 'is destroyed' do
        item_name = @list_items.first.pretty_title

        list_page.accept_alert do
          list_page.delete item_name
        end

        list_page.wait_for_not_purchased_items
        list_page.wait_for_item_deleted_alert
        expect(list_page.not_purchased_items.map(&:text)).to_not include item_name
      end
    end

    describe 'that is purchased' do
      it 'is refreshed' do
        item_name = @list_items.last.pretty_title

        list_page.refresh item_name

        wait_for do
          list_page.not_purchased_items.count == 2
        end

        expect(list_page.not_purchased_items.map(&:text)).to include item_name
      end

      it 'is destroyed' do
        item_name = @list_items.last.pretty_title

        list_page.accept_alert do
          list_page.delete item_name, purchased: true
        end

        wait_for do
          list_page.purchased_items.count.zero?
        end

        expect(list_page.purchased_items.map(&:text)).to_not include item_name
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

      expect(list_page).to have_quantity_input
      expect(list_page).to have_product_input
      expect(list_page).to have_submit_button
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
      expect(not_purchased_item).to have_no_css list_page.purchase_button_css
      expect(not_purchased_item).to have_no_css list_page.edit_button_css
      expect(not_purchased_item).to have_no_css list_page.delete_button_css
      expect(purchased_item).to have_no_css list_page.refresh_button_css
      expect(purchased_item).to have_no_css list_page.delete_button_css
    end
  end
end
