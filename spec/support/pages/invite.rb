# frozen_string_literal: true

module Pages
  # invite page
  class Invite < SitePrism::Page
    set_url '/users/invitation/new'

    element :email, '#email'
    element :submit, "button[type='submit']"
  end
end
