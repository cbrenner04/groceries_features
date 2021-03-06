# frozen_string_literal: true

module Pages
  # login page, including forgot password and sign up
  class Login < SitePrism::Page
    set_url "/users/sign_in"

    element :email, "#email"
    element :forgot_password, "a[href='/users/password/new']"
    element :log_in, "a[href='/users/sign_in']"
    element :password, "#password"
    element :password_confirmation, "input[name='passwordConfirmation']"
    element :sign_up, "a[href='/users']"
    element :submit, "button[type='submit']"
  end
end
