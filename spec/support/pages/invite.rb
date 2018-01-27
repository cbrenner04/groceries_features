# frozen_string_literal: true

module Pages
  # invite page
  class Invite < SitePrism::Page
    set_url '/users/invitation/new'

    element :email, "input[name='newEmail']"
    element :submit, "input[type='submit']"
  end
end
