# frozen_string_literal: true

require 'spec_helper'

RSpec.feature 'A grocery list item' do
  let(:list_page) { Pages::List.new }
  let(:edit_list_item_page) { Pages::EditListItem.new }
  let(:user) { Models::User.new }
  let(:list) { Models::List.new(type: 'GroceryList') }

  before do
    @list_items = create_associated_list_objects(user, list)

    login user
    list_page.load(id: list.id)
  end

  it 'is created' do
    new_list_item = Models::GroceryListItem.new(user_id: user.id,
                                                grocery_list_id: list.id,
                                                create_item: false)

    list_page.quantity.set new_list_item.quantity
    list_page.quantity_name.set new_list_item.quantity_name
    list_page.name.set new_list_item.name
    list_page.submit.click

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

      item.name = SecureRandom.hex(16)

      wait_for do
        edit_list_item_page.name.set item.name
        edit_list_item_page.name.value == item.name
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
