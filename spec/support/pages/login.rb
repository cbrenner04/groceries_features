# frozen_string_literal: true

module Pages
  # login page, including forgot password and sign up
  class Login < SitePrism::Page
    set_url '/'

    element :email, "input[name='email']"
    element :password, "input[name='password']"
    element :submit, "input[type='submit']"
  end
end
