# frozen_string_literal: true

module Helpers
  # helpers for waiting
  module WaitHelper
    def wait_for
      @counter ||= 0
      until (yield if block_given?) || wait_time_lapsed?
        sleep 1
        @counter += 1
      end
    end

    private

    def wait_time_lapsed?
      @counter > Capybara.default_max_wait_time
    end
  end
end
