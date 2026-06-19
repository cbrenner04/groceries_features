# frozen_string_literal: true

RSpec.shared_examples "a list item" do |edit_attribute, template_name, item_class, bulk_update_attrs|
  def update_attrs(bulk_attrs)
    bulk_attrs.each do |attr|
      if attr == "assignee"
        edit_list_items_page.assignee.set user.email
      else
        value = ["due by", "due_by"].include?(attr) ? "02/02/2020" : "foobar"
        edit_list_items_page.send(attr).set value
      end
    end
  end

  def bulk_updated_value(attr)
    return user.email if attr == "assignee"
    return Time.parse("February 2, 2020") if ["due_by", "due by"].include?(attr)

    "foobar"
  end

  def apply_bulk_update_values(bulk_attrs)
    bulk_attrs.each do |attr|
      value = bulk_updated_value(attr)
      setter = (attr == "assignee" ? "assignee_email=" : "#{attr}=")
      @list_items.each do |item|
        next if item.send("completed")

        item.send(setter, value)
      end
    end
  end

  # Copy/move create new records, so assert the destination list shows the expected number of
  # not-completed items and that each live record renders.
  def expect_copied_items_on(list_id)
    item_ids = not_completed_item_ids(list_id)
    expect(item_ids.count).to eq(@list_items.count { |item| !item.send("completed") })
    item_ids.each { |id| expect(list_page.find_list_item(id, completed: false)).to be_visible }
  end

  describe "when logged in as owner" do
    before do
      login user
      list_page.load(id: list.id)
      @initial_list_item_count = list_page.not_completed_items.count
    end

    it "is created" do
      new_list_item = item_class.new(user_id: user.id, list_id: list.id, create_item: false, category: "foo",
                                     list_item_configuration_id: list.list_item_configuration.id)

      list_page.expand_list_item_form

      # `input_new_item_attribute` is defined in the spec that executes this shared example as it is different for each
      send("input_new_item_attributes", new_list_item)
      list_page.category_input.set(new_list_item.category)

      list_page.submit_add_item

      wait_for { list_page.not_completed_items.count == @initial_list_item_count + 1 }

      expect(list_page.not_completed_items.count).to eq @initial_list_item_count + 1
      # `confirm_form_cleared` is defined in the spec that executes this shared example as it is different for each
      send("confirm_form_cleared")

      category_headers = list_page.category_header.map(&:text)

      expected_category = new_list_item.category.upcase
      expect(category_headers.any? { |header| header.include?(expected_category) }).to be(true)
    end

    it "is created as completed when checkbox is checked" do
      initial_completed_items_count = list_page.completed_items.count
      new_list_item = item_class.new(user_id: user.id, list_id: list.id, create_item: false, category: "foo",
                                     list_item_configuration_id: list.list_item_configuration.id)

      list_page.expand_list_item_form

      # Input item attributes
      send("input_new_item_attributes", new_list_item)
      list_page.category_input.set(new_list_item.category)

      # Check the completed checkbox
      list_page.completed_checkbox.click

      list_page.submit_add_item

      # Item should appear in completed items, not in not_completed_items
      wait_for { list_page.completed_items.count == initial_completed_items_count + 1 }

      expect(list_page.completed_items.count).to eq initial_completed_items_count + 1
      expect(list_page.not_completed_items.count).to eq @initial_list_item_count

      # Verify form is cleared including the checkbox
      send("confirm_form_cleared")
      expect(list_page.completed_checkbox).not_to be_checked
    end

    describe "that is not completed" do
      it "is completed" do
        initial_completed_items_count = list_page.completed_items.count

        list_page.complete @list_items.first

        wait_for { list_page.completed_items.count == initial_completed_items_count + 1 }

        expect(list_page.find_list_item(@list_items.first, completed: true)).to be_visible
      end

      it "is edited" do
        item = @list_items.first

        list_page.edit item

        item.send("#{edit_attribute}=", SecureRandom.hex(16))

        wait_for do
          edit_list_item_page.send(edit_attribute).set item.send(edit_attribute)
          edit_list_item_page.send(edit_attribute).value == item.send(edit_attribute)
        end

        edit_list_item_page.submit.click

        wait_for { page.has_text?("Item successfully updated") }

        list_page.load(id: list.id)
        list_page.wait_until_not_completed_items_visible

        expect(list_page.find_list_item(item, completed: false)).to be_visible
      end

      it "is destroyed" do
        item_name = @list_items.first.pretty_title

        list_page.delete @list_items.first
        list_page.wait_until_confirm_delete_button_visible

        # for some reason if the button is clicked to early it doesn't work
        sleep 1

        list_page.confirm_delete_button.click

        wait_for { list_page.item_deleted_alert.visible? }

        expect(list_page.not_completed_items.count).to eq @initial_list_item_count - 1
        not_completed_texts = list_page.not_completed_items.map(&:text)
        expect(not_completed_texts.select { |text| text == item_name }).to be_empty
      end

      describe "when a filter is applied" do
        before do
          list_page.wait_until_completed_items_visible
          list_page.filter_option("foo").click
        end

        it "is edited" do
          item = @list_items.first

          list_page.edit item

          item.send("#{edit_attribute}=", SecureRandom.hex(16))

          wait_for do
            edit_list_item_page.send(edit_attribute).set item.send(edit_attribute)
            edit_list_item_page.send(edit_attribute).value == item.send(edit_attribute)
          end

          edit_list_item_page.submit.click

          wait_for { page.has_text?("Item successfully updated") }

          list_page.load(id: list.id)
          list_page.wait_until_not_completed_items_visible
          wait_for { list_page.has_filter_option?("foo") }
          list_page.filter_option("foo").click

          expect(list_page.find_list_item(item, completed: false)).to be_visible
        end

        describe "when there is only one item for the selected category" do
          it "is completed" do
            item_name = @list_items.first.pretty_title
            incomplete_item_count_start = list_page.not_completed_items.count
            completed_item_count_start = list_page.completed_items.count

            list_page.complete @list_items.first

            wait_for { list_page.completed_items.count == incomplete_item_count_start + 1 }

            expect(list_page.not_completed_items.count).to eq incomplete_item_count_start - 1
            expect(list_page.completed_items.count).to eq completed_item_count_start + 1
            not_completed_texts = list_page.not_completed_items.map(&:text)
            expect(not_completed_texts.select { |text| text == item_name }).to be_empty
            expected_parts = @list_items[1].pretty_title.split("\n").map(&:strip).reject(&:empty?)
            expect(not_completed_texts.any? { |text| expected_parts.all? { |part| text.include?(part) } }).to be(false)
            expect(list_page.find_list_item(@list_items.first, completed: true)).to be_visible

            # no longer filtered
            list_page.clear_filter_button.click
            wait_for { list_page.not_completed_items.one? }

            # After clearing filter, should see the remaining incomplete item
            expect(list_page.find_list_item(@list_items[1], completed: false)).to be_visible
            expect(list_page.not_completed_items.count).to eq 1
          end

          it "is destroyed" do
            item_name = @list_items.first.pretty_title
            incomplete_item_count_start = list_page.not_completed_items.count

            list_page.delete @list_items.first
            list_page.wait_until_confirm_delete_button_visible

            list_page.confirm_delete_button.click
            expect(list_page).to have_item_deleted_alert

            wait_for { list_page.not_completed_items.count == incomplete_item_count_start - 1 }

            expect(list_page.not_completed_items.count).to eq incomplete_item_count_start - 1
            not_completed_texts = list_page.not_completed_items.map(&:text)
            expect(not_completed_texts.select { |text| text == item_name }).to be_empty
            expected_parts = @list_items[1].pretty_title.split("\n").map(&:strip).reject(&:empty?)
            expect(not_completed_texts.any? { |text| expected_parts.all? { |part| text.include?(part) } }).to be(false)

            # no longer filtered
            list_page.clear_filter_button.click
            wait_for { list_page.not_completed_items.one? }

            # After clearing filter, should see the remaining incomplete item
            expect(list_page.find_list_item(@list_items[1], completed: false)).to be_visible
            expect(list_page.not_completed_items.count).to eq 1
          end
        end

        describe "when there are multiple items for the selected category" do
          before do
            @another_list_item = item_class.new(user_id: user.id, list_id: list.id, category: "foo",
                                                list_item_configuration_id: list.list_item_configuration.id)
            # need to wait for the item to be added
            # TODO: do something better
            sleep 1
            # due to adding data above we need to reload page and filter again
            list_page.load(id: list.id)
            list_page.wait_until_completed_items_visible
            list_page.filter_option("foo").click
          end

          it "is completed" do
            initial_completed_count = list_page.completed_items.count
            initial_not_completed_count = list_page.not_completed_items.count

            list_page.complete @list_items.first

            wait_for do
              list_page.completed_items.count == initial_completed_count + 1 &&
                list_page.not_completed_items.count == initial_not_completed_count - 1
            end

            expect(list_page.find_list_item(@list_items.first, completed: true)).to be_visible
            expect(list_page.find_list_item(@another_list_item, completed: false)).to be_visible
            expect(list_page.has_no_list_item?(@list_items.first, completed: false)).to be true
          end

          it "is destroyed" do
            initial_list_item_count = list_page.not_completed_items.count
            item_name = @list_items.first.pretty_title

            list_page.delete @list_items.first
            list_page.wait_until_confirm_delete_button_visible

            # for some reason if the button is clicked to early it doesn't work
            # TODO: do something better
            sleep 1

            list_page.confirm_delete_button.click

            wait_for { list_page.not_completed_items.count == initial_list_item_count - 1 }

            expect(list_page.not_completed_items.count).to eq initial_list_item_count - 1
            expect(list_page).to have_item_deleted_alert
            not_completed_texts = list_page.not_completed_items.map(&:text)
            expect(not_completed_texts.select { |text| text == item_name }).to be_empty
            expect(list_page.find_list_item(@another_list_item, completed: false)).to be_visible
          end
        end
      end
    end

    describe "that is completed" do
      it "is destroyed" do
        initial_completed_items_count = list_page.completed_items.count
        item_name = @list_items.last.pretty_title

        list_page.delete @list_items.last, completed: true
        list_page.wait_until_confirm_delete_button_visible

        # for some reason if the button is clicked too early it doesn't work
        sleep 1

        list_page.confirm_delete_button.click

        wait_for { list_page.completed_items.count == initial_completed_items_count - 1 }

        completed_texts = list_page.completed_items.map(&:text)
        expect(completed_texts.select { |text| text == item_name }).to be_empty
      end
    end

    describe "when multiple selected" do
      it "is completed" do
        list_page.multi_select_buttons.first.click
        @list_items.each do |item|
          next if item.send("completed")

          list_page.multi_select_item(item, completed: item.send("completed"))
        end

        list_page.complete(@list_items.first)

        wait_for { list_page.not_completed_items.none? }

        expect(list_page.not_completed_items.count).to eq 0
        expect(list_page.completed_items.count).to eq 3
      end

      context "when items are not completed" do
        it "is destroyed" do
          list_page.multi_select_buttons.first.click
          @list_items.each do |item|
            next if item.send("completed")

            list_page.multi_select_item(item, completed: false)
          end
          list_page.delete(@list_items.first, completed: false)
          list_page.wait_until_confirm_delete_button_visible

          # for some reason if the button is clicked too early it doesn't work
          sleep 1

          list_page.confirm_delete_button.click

          wait_for { list_page.not_completed_items.none? }

          expect(list_page.not_completed_items.count).to eq 0
        end
      end

      context "when items are completed" do
        it "is destroyed" do
          list_page.multi_select_buttons.last.click
          completed_items = @list_items.filter { |item| item.send("completed") }
          completed_items.each { |item| list_page.multi_select_item(item, completed: true) }
          list_page.delete(completed_items.first, completed: true)
          list_page.wait_until_confirm_delete_button_visible

          # for some reason if the button is clicked too early it doesn't work
          sleep 1

          list_page.confirm_delete_button.click

          wait_for { list_page.completed_items.none? }

          expect(list_page.completed_items.count).to eq 0
        end
      end

      describe "when copy" do
        it "creates a new list" do
          list_page.multi_select_buttons.first.click
          @list_items.each do |item|
            next if item.send("completed")

            list_page.multi_select_item(item, completed: false)
          end
          list_page.copy_to_list.click

          change_other_list_modal.wait_until_new_list_name_input_visible

          # cannot choose existing list when no other lists exist
          all_link_text = change_other_list_modal.all_links.map(&:text)

          expect(all_link_text.select { |text| text == "Choose existing list" }).to be_empty

          # create new list
          change_other_list_modal.new_list_name_input.set "foobar"
          change_other_list_modal.complete.click

          wait_for { page.has_text?("Items successfully updated") }
          wait_for { change_other_list_modal.has_no_modal? }

          # check new list for new items
          home_page.load
          home_page.select_list "foobar"
          list_page.wait_until_not_completed_items_visible

          # all items should exist on this list
          expect_copied_items_on(list_id_by_name("foobar", user.id))
        end

        it "chooses existing list" do
          # create another list so option for existing list are available
          new_list = Models::List.new(template_name: template_name, owner_id: user.id,
                                      list_item_configuration: list.list_item_configuration)
          Models::UsersList.new(user_id: user.id, list_id: new_list.id)

          page.refresh
          list_page.multi_select_buttons.first.click
          @list_items.each do |item|
            next if item.send("completed")

            list_page.multi_select_item(item, completed: false)
          end
          list_page.copy_to_list.click

          change_other_list_modal.existing_list_dropdown.select new_list.name
          change_other_list_modal.complete.click

          wait_for { page.has_text?("Items successfully updated") }
          wait_for { change_other_list_modal.has_no_modal? }

          list_page.load(id: list.id)
          list_page.wait_until_not_completed_items_visible

          # go to existing list
          list_page.load(id: new_list.id)
          list_page.wait_until_not_completed_items_visible

          wait_for { list_page.not_completed_items.count == @list_items.count { |item| !item.send("completed") } }

          # all items should exist on this list
          expect_copied_items_on(new_list.id)
        end
      end

      describe "when move" do
        it "creates a new list" do
          list_page.multi_select_buttons.first.click
          @list_items.each do |item|
            next if item.send("completed")

            list_page.multi_select_item(item, completed: false)
          end
          list_page.move_to_list.click

          change_other_list_modal.wait_until_new_list_name_input_visible

          # cannot choose existing list when no other lists exist
          all_link_text = change_other_list_modal.all_links.map(&:text)

          expect(all_link_text.select { |text| text == "Choose existing list" }).to be_empty

          # create new list
          change_other_list_modal.new_list_name_input.set "foobar"
          change_other_list_modal.complete.click

          wait_for { page.has_text?("Items successfully updated") }
          wait_for { change_other_list_modal.has_no_modal? }

          # selected items should not be on this list any longer
          wait_for { list_page.not_completed_items.none? }

          # check new list for new items
          home_page.load
          home_page.select_list "foobar"
          list_page.wait_until_not_completed_items_visible

          # all items should exist on new list
          expect_copied_items_on(list_id_by_name("foobar", user.id))
        end

        it "chooses existing list" do
          # create another list so option for existing list are available
          new_list = Models::List.new(template_name: template_name, owner_id: user.id,
                                      list_item_configuration: list.list_item_configuration)
          Models::UsersList.new(user_id: user.id, list_id: new_list.id)

          page.refresh
          list_page.multi_select_buttons.first.click
          @list_items.each do |item|
            next if item.send("completed")

            list_page.multi_select_item(item, completed: false)
          end
          list_page.move_to_list.click

          change_other_list_modal.existing_list_dropdown.select new_list.name
          change_other_list_modal.complete.click

          wait_for { page.has_text?("Items successfully updated") }
          wait_for { change_other_list_modal.has_no_modal? }

          # selected items should not be on this list any longer
          wait_for { list_page.not_completed_items.none? }

          # go to existing list
          list_page.load(id: new_list.id)
          list_page.wait_until_not_completed_items_visible

          # all items should exist on this list
          expect_copied_items_on(new_list.id)
        end
      end

      describe "when edited" do
        before do
          list_page.multi_select_buttons.first.click
          @list_items.each do |item|
            next if item.send("completed")

            list_page.multi_select_item(item, completed: false)
          end
          list_page.bulk_edit_button.click
        end

        it "updates all attributes for items" do
          wait_for { list_page.has_test_id?("bulk-edit-sheet") }

          # change attributes to new attributes
          update_attrs(bulk_update_attrs)
          edit_list_items_page.category.set "foobaz"
          edit_list_items_page.submit.click

          wait_for { page.has_text?("Items successfully updated") }

          list_page.load(id: list.id)
          apply_bulk_update_values(bulk_update_attrs)
          @list_items.each do |item|
            next if item.send("completed")

            item.category = "foobaz"
          end
          list_page.wait_until_not_completed_items_visible

          # all items should now have the same category "foobaz"
          category_headers = list_page.category_header.map(&:text)
          expect(category_headers.count).to eq 1
          expect(category_headers).to include(a_string_matching(/foobaz/i))

          # all items should now have the same attributes set to "foobar"
          @list_items.each do |item|
            next if item.send("completed")

            label = list_page.find_list_item(item, completed: false).text

            expect(label.downcase).to include(item.pretty_title.downcase)
          end

          # return to edit page for clearing below
          list_page.multi_select_buttons.first.click
          @list_items.each do |item|
            next if item.send("completed")

            list_page.multi_select_item(item, completed: false)
          end
          list_page.bulk_edit_button.click

          wait_for { list_page.has_test_id?("bulk-edit-sheet") }

          # clear attributes
          bulk_update_attrs.each { |attr| edit_list_items_page.send("clear_#{attr}").click }
          edit_list_items_page.clear_category.click
          edit_list_items_page.submit.click

          wait_for { page.has_text?("Items successfully updated") }

          list_page.load(id: list.id)
          list_page.wait_until_not_completed_items_visible

          # all items should have add their categories cleared
          headers = list_page.category_header.map(&:text)
          expect(headers.count).to eq 1
          expect(headers).to include(a_string_matching(/other/i))

          # all items should have had their attributes cleared
          @list_items.each do |item|
            next if item.send("completed")

            label = list_page
                    .find_list_item(item, completed: false)
                    .text

            if template_name == "to do list template"
              expect(label).not_to include user.email
              expect(label).not_to include "February 2, 2020"
            else
              expect(label).not_to include "foobar"
            end
          end
        end
      end
    end
  end
end
