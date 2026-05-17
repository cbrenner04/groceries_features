# frozen_string_literal: true

module Helpers
  # Temporary diagnostic helper for capturing DOM state on wait failures
  # Only active when CAPTURE_WAIT_DIAGNOSTICS=1
  module DiagnosticHelper
    def self.capture_on_wait_failure(exception, current_page)
      return unless ENV["CAPTURE_WAIT_DIAGNOSTICS"] == "1"

      timestamp = Time.now.strftime("%Y%m%d_%H%M%S_%3N")
      diagnostics_dir = "spec/diagnostics"
      Dir.mkdir(diagnostics_dir) unless Dir.exist?(diagnostics_dir)

      # Save HTML
      html_path = File.join(diagnostics_dir, "wait_failure_#{timestamp}.html")
      File.write(html_path, current_page.html)

      # Save screenshot
      screenshot_path = File.join(diagnostics_dir, "wait_failure_#{timestamp}.png")
      current_page.save_screenshot(screenshot_path)

      # Save a note about what we were waiting for
      note_path = File.join(diagnostics_dir, "wait_failure_#{timestamp}.txt")
      File.write(note_path, "Exception: #{exception.inspect}\n\nScreenshot: #{screenshot_path}\nHTML dump: #{html_path}")

      puts "\n\n[DIAGNOSTIC] Wait failure captured:"
      puts "  HTML: #{html_path}"
      puts "  Screenshot: #{screenshot_path}"
      puts "  Note: #{note_path}"
      puts "\n"
    end
  end
end
