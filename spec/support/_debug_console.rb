# frozen_string_literal: true

RSpec.configure do |config|
  config.after(type: :feature) do
    logs = page.driver.browser.logs.get(:browser)
    warn "\n===== BROWSER CONSOLE (#{logs.size}) ====="
    logs.each { |e| warn "[#{e.level}] #{e.message}" }
    warn "===== END CONSOLE =====\n"
  end
end
