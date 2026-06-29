# frozen_string_literal: true

module Pages
  class Templates < SitePrism::Page
    include TestSelectors
    include Helpers::WaitHelper

    set_url "/templates"

    element :header, "h1", text: "Templates"
    # Templates are created via a modal opened by the floating "+" button; the submit lives in
    # the modal footer.
    element :submit, "[data-test-id='create-template-submit']"

    def manage_templates
      find_by_test_id("nav-templates").click
    end

    # Opens the create-template modal via the floating "+" button and waits for it to render.
    def expand_template_form
      find_by_test_id("templates-create-fab").click
      wait_for { has_test_id?("create-template-modal") }
    end

    def has_templates?
      has_test_class?("template")
    end

    def has_no_templates?
      has_no_test_class?("template")
    end

    def template_names
      all_by_test_class("template").map { |t| t.find("h3").text }
    end

    def template_name_input
      find_by_test_id("create-template-name-input")
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
      trash = find_by_test_id_within(template_element, "template-trash")
      # The floating "+" create button can overlap a freshly added template's actions, so a normal
      # click may be intercepted. Center it and click via JS to trigger the button's handler.
      trash.execute_script("this.scrollIntoView({ block: 'center' }); this.click();")
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
