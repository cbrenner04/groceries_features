# frozen_string_literal: true

module Pages
  # app home page, displayed after log in, displays lists
  class Home < SitePrism::Page
    COMPLETE_LIST = "div[data-test-class='completed-list']"
    INCOMPLETE_LIST = "div[data-test-class='non-completed-list']"
    COMPLETE_BUTTON = '.fa.fa-check-square-o'
    DELETE_BUTTON = '.fa.fa-trash'
    SHARE_BUTTON = '.fa.fa-users'
    EDIT_BUTTON = '.fa.fa-pencil-square-o'
    REFRESH_BUTTON = '.fa.fa-refresh'

    set_url '/'

    element :signed_in_alert, '.alert', text: 'Signed in successfully'
    element :list_deleted_alert,
            '.alert',
            text: 'Your list was successfully deleted'
    element :list_type, "select[name='listType']"
    element :header, 'h1', text: 'Lists'
    element :name, "input[name='listName']"
    element :submit, "button[type='submit']"
    element :invite, '#invite-link'
    element :log_out, '#log-out-link'

    elements :complete_lists, COMPLETE_LIST
    elements :complete_list_names, "#{COMPLETE_LIST} h5"
    elements :incomplete_lists, INCOMPLETE_LIST
    elements :incomplete_list_names, "#{INCOMPLETE_LIST} h5"

    def select_list(list_name)
      click_on list_name
    end

    def complete(list_name)
      find(INCOMPLETE_LIST, text: list_name)
        .find(COMPLETE_BUTTON)
        .click
    end

    def share(list_name)
      find(INCOMPLETE_LIST, text: list_name).find(SHARE_BUTTON).click
    end

    def edit(list_name)
      find(INCOMPLETE_LIST, text: list_name)
        .find(EDIT_BUTTON)
        .click
    end

    def delete(list_name, complete: false)
      list_css = complete ? COMPLETE_LIST : INCOMPLETE_LIST
      find(list_css, text: list_name).find(DELETE_BUTTON).click
    end

    def refresh(list_name)
      find(COMPLETE_LIST, text: list_name).find(REFRESH_BUTTON).click
    end
  end
end
