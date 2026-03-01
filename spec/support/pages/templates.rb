# frozen_string_literal: true

module Pages
  class Templates < SitePrism::Page
    include TestSelectors
    include Helpers::WaitHelper

    set_url "/templates"

    element :header, "h1", text: "Templates"
    element :submit, "button[type='submit']"

    def manage_templates
      find_by_test_id("manage-templates-link").click
    end

    def expand_template_form
      find_by_test_id("add-template-button").click
    end

    def has_templates?
      has_test_class?("template")
    end

    def has_no_templates?
      has_no_test_class?("template")
    end

    def template_names
      all_by_test_class("template").map { |t| t.find("h5").text }
    end

    def template_name_input
      find_by_test_id("template-form-name")
    end

    def field_configuration_rows
      all_by_test_class("field-configuration-row")
    end

    def edit(template_name)
      template_element = find_by_test_class("template", text: template_name)
      find_by_test_id_within(template_element, "template-edit").click
    end

    def delete(template_name)
      template_element = find_by_test_class("template", text: template_name)
      find_by_test_id_within(template_element, "template-trash").click
    end

    def confirm_delete_button
      find_by_test_id("confirm-delete")
    end

    def has_confirm_delete?
      has_test_id?("confirm-delete")
    end

    def wait_until_confirm_delete_button_visible
      wait_for { has_test_id?("confirm-delete") }
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
  end
end
