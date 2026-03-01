# frozen_string_literal: true

module Pages
  class EditTemplate < SitePrism::Page
    include TestSelectors
    include Helpers::WaitHelper

    set_url "/templates/{id}/edit"

    element :header, "h1", text: "Edit Template"
    element :submit, "button[type='submit']"

    def template_name_input
      find_by_test_id("template-name")
    end

    def add_field_button
      find_by_test_id("add-field-button")
    end

    def field_label_input(index)
      find_by_test_id("field-row-label-#{index}")
    end

    def field_data_type_select(index)
      find_by_test_id("field-row-data-type-#{index}")
    end

    def field_position_input(index)
      find_by_test_id("field-row-position-#{index}")
    end

    def field_primary_checkbox(index)
      find_by_test_id("field-row-primary-#{index}")
    end

    def remove_field_button(index)
      find_by_test_id("field-row-remove-#{index}")
    end

    def field_rows
      all_by_test_class("field-configuration-row")
    end

    def cancel_button
      find(:button, text: "Cancel")
    end
  end
end
