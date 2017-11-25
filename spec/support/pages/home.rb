# frozen_string_literal: true

module Pages
  # app home page, displayed after log in
  class Home < SitePrism::Page
    set_url '/'

    element :header, 'h1', text: 'Lists'
  end
end
