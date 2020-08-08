# frozen_string_literal: true

RSpec.shared_examples "a list item" do |edit_attribute, list_id_attr, item_class|
  describe "when logged in as owner" do
    before do
      login user
      list_page.load(id: list.id)
      @initial_list_item_count = list_page.not_purchased_items.count
    end

    it "is created" do
      new_list_item = item_class.new(user_id: user.id, list_id_attr.to_sym => list.id, create_item: false,
                                     category: "foo")

      list_page.expand_list_item_form
      send("input_new_item_attributes", new_list_item)
      list_page.category_input.set new_list_item.category
      list_page.submit_button.click

      wait_for { list_page.not_purchased_items.count == @initial_list_item_count + 1 }

      expect(list_page.not_purchased_items.map(&:text)).to include new_list_item.pretty_title

      category_headers = list_page.category_header.map(&:text)

      expect(category_headers.count).to eq 1
      expect(category_headers.first).to eq new_list_item.category.capitalize
    end

    describe "that is not purchased" do
      it "is purchased" do
        item_name = @list_items.first.pretty_title

        list_page.purchase item_name

        wait_for { list_page.purchased_items.count == @initial_list_item_count + 1 }

        expect(list_page.purchased_items.map(&:text)).to include item_name
      end

      it "is edited" do
        item = @list_items.first

        list_page.edit item.pretty_title

        item.send("#{edit_attribute}=", SecureRandom.hex(16))

        wait_for do
          edit_list_item_page.send(edit_attribute).set item.send(edit_attribute)
          edit_list_item_page.send(edit_attribute).value == item.send(edit_attribute)
        end

        edit_list_item_page.submit.click

        expect(list_page.not_purchased_items.map(&:text)).to include item.pretty_title
      end

      it "is destroyed" do
        item_name = @list_items.first.pretty_title

        list_page.delete item_name
        list_page.wait_until_confirm_delete_button_visible

        # for some reason if the button is clicked to early it doesn't work
        sleep 1

        list_page.confirm_delete_button.click

        wait_for { list_page.not_purchased_items.count == @initial_list_item_count - 1 }

        expect(list_page.not_purchased_items.count).to eq @initial_list_item_count - 1
        expect(list_page).to have_item_deleted_alert
        expect(list_page.not_purchased_items.map(&:text)).not_to include item_name
      end

      describe "when a filter is applied" do
        before do
          list_page.wait_until_purchased_items_visible
          list_page.filter_button.click
          list_page.filter_option("foo").click
        end

        it "is edited" do
          item = @list_items.first

          list_page.edit item.pretty_title

          item.send("#{edit_attribute}=", SecureRandom.hex(16))

          wait_for do
            edit_list_item_page.send(edit_attribute).set item.send(edit_attribute)
            edit_list_item_page.send(edit_attribute).value == item.send(edit_attribute)
          end

          edit_list_item_page.submit.click
          list_page.wait_until_not_purchased_items_visible
          list_page.filter_button.click
          list_page.filter_option("foo").click

          expect(list_page.not_purchased_items.map(&:text)).to include item.pretty_title
        end

        describe "when there is only one item for the selected category" do
          it "is purchased" do
            item_name = @list_items.first.pretty_title

            list_page.purchase item_name

            wait_for { list_page.purchased_items.count == @initial_list_item_count + 1 }

            expect(list_page.purchased_items.map(&:text)).to include item_name
            # no longer filtered
            expect(list_page.not_purchased_items.map(&:text)).to include @list_items[1].pretty_title
          end

          it "is destroyed" do
            item_name = @list_items.first.pretty_title

            list_page.delete item_name
            list_page.wait_until_confirm_delete_button_visible

            # for some reason if the button is clicked to early it doesn't work
            sleep 1

            list_page.confirm_delete_button.click

            wait_for { list_page.not_purchased_items.count == @initial_list_item_count - 1 }

            expect(list_page.not_purchased_items.count).to eq @initial_list_item_count - 1
            expect(list_page).to have_item_deleted_alert
            expect(list_page.not_purchased_items.map(&:text)).not_to include item_name
            # no longer filtered
            expect(list_page.not_purchased_items.map(&:text)).to include @list_items[1].pretty_title
          end
        end

        describe "when there are multiple items for the selected category" do
          before do
            @another_list_item = item_class.new(user_id: user.id, list_id_attr.to_sym => list.id, category: "foo")
            @initial_list_item_count += 1
            # need to wait for the item to be added
            # TODO: do something better
            sleep 1
            # due to adding data above we need to reload page and filter again
            list_page.load(id: list.id)
            list_page.wait_until_purchased_items_visible
            list_page.filter_button.click
            list_page.filter_option("foo").click
          end

          it "is purchased" do
            item_name = @list_items.first.pretty_title

            list_page.purchase item_name

            wait_for { list_page.purchased_items.count == @initial_list_item_count + 1 }

            not_purchased_list_items = list_page.not_purchased_items.map(&:text)

            expect(list_page.purchased_items.map(&:text)).to include item_name
            expect(not_purchased_list_items).to include @another_list_item.pretty_title
            expect(not_purchased_list_items).not_to include @list_items[1].pretty_title
          end

          it "is destroyed" do
            initial_list_item_count = list_page.not_purchased_items.count
            item_name = @list_items.first.pretty_title

            list_page.delete item_name
            list_page.wait_until_confirm_delete_button_visible

            # for some reason if the button is clicked to early it doesn't work
            # TODO: do something better
            sleep 1

            list_page.confirm_delete_button.click

            wait_for { list_page.not_purchased_items.count == initial_list_item_count - 1 }

            expect(list_page.not_purchased_items.count).to eq initial_list_item_count - 1
            expect(list_page).to have_item_deleted_alert
            expect(list_page.not_purchased_items.map(&:text)).not_to include item_name
            expect(list_page.not_purchased_items.map(&:text)).to include @another_list_item.pretty_title
            expect(list_page.not_purchased_items.map(&:text)).not_to include @list_items[1].pretty_title
          end
        end
      end
    end

    describe "that is purchased" do
      it "is destroyed" do
        initial_purchase_items_count = list_page.purchased_items.count
        item_name = @list_items.last.pretty_title

        list_page.delete item_name, purchased: true
        list_page.wait_until_confirm_delete_button_visible

        # for some reason if the button is clicked too early it doesn't work
        sleep 1

        list_page.confirm_delete_button.click

        wait_for { list_page.purchased_items.count == initial_purchase_items_count - 1 }

        expect(list_page.purchased_items.map(&:text)).not_to include item_name
      end
    end

    describe "when multiple selected" do
      purchased_attr = list_id_attr == "to_do_list_id" ? "completed" : "purchased"

      it "is purchased" do
        list_page.multi_select_button.click
        @list_items.each { |item| list_page.multi_select_item(item.pretty_title, purchased: item.send(purchased_attr)) }
        list_page.purchase(@list_items.first.pretty_title)

        wait_for { list_page.not_purchased_items.count == 0 }

        expect(list_page.not_purchased_items.count).to eq 0
        expect(list_page.purchased_items.count).to eq 3
      end

      it "is destroyed" do
        list_page.multi_select_button.click
        @list_items.each { |item| list_page.multi_select_item(item.pretty_title, purchased: item.send(purchased_attr)) }
        list_page.delete(@list_items.first.pretty_title, purchased: false)
        list_page.wait_until_confirm_delete_button_visible

        # for some reason if the button is clicked too early it doesn't work
        sleep 1

        list_page.confirm_delete_button.click

        wait_for { list_page.not_purchased_items.count == 0 }

        expect(list_page.not_purchased_items.count).to eq 0
        expect(list_page.purchased_items.count).to eq 0
      end
    end
  end
end
