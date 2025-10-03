# frozen_string_literal: true

module Helpers
  # helpers for waiting
  module WaitHelper
    def wait_for
      counter = 0
      original_wait_time = Capybara.default_max_wait_time

      until wait_time_lapsed?(counter, original_wait_time)
        begin
          Capybara.default_max_wait_time = 0

          return if block_given? && yield
        rescue StandardError
          # noop - just gonna retry
        ensure
          Capybara.default_max_wait_time = original_wait_time
          counter += 1
        end
        sleep 1
      end
    ensure
      Capybara.default_max_wait_time = original_wait_time
    end

    private

    def wait_time_lapsed?(counter, original_wait_time)
      throw "full wait time lapsed" if counter > original_wait_time

      false
    end
  end
end
