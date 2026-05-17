# frozen_string_literal: true

module Helpers
  # Controlled React inputs do not always sync when using Capybara/SitePrism #set alone.
  module ReactInput
    def react_fill_in(css_selector, with:)
      el = find(:css, css_selector)
      page.driver.browser.execute_script(<<~JS, el.native, with.to_s)
        (function(el, val) {
          var nativeSetter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
          nativeSetter.call(el, val);
          el.dispatchEvent(new Event('input', { bubbles: true }));
          el.dispatchEvent(new Event('change', { bubbles: true }));
        })(arguments[0], arguments[1]);
      JS
    end
  end
end
