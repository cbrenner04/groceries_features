# frozen_string_literal: true

module Pages
  # Helper methods for data-test-id and data-test-class selectors
  module TestSelectors
    def find_by_test_id(test_id, **options)
      find("[data-test-id='#{test_id}']", **options)
    end

    def find_by_test_class(test_class, **options)
      find("[data-test-class='#{test_class}']", **options)
    end

    def all_by_test_id(test_id, **options)
      all("[data-test-id='#{test_id}']", **options)
    end

    def all_by_test_class(test_class, **options)
      all("[data-test-class='#{test_class}']", **options)
    end

    def has_test_id?(test_id)
      has_css?("[data-test-id='#{test_id}']")
    end

    def has_test_class?(test_class)
      has_css?("[data-test-class='#{test_class}']")
    end

    def has_no_test_id?(test_id)
      has_no_css?("[data-test-id='#{test_id}']")
    end

    def has_no_test_class?(test_class)
      has_no_css?("[data-test-class='#{test_class}']")
    end

    def click_test_id(test_id)
      find_by_test_id(test_id).click
    end

    def click_test_class(test_class)
      find_by_test_class(test_class).click
    end

    # Helper method to find by test-id within a found element
    def find_by_test_id_within(element, test_id)
      element.find("[data-test-id='#{test_id}']")
    end

    # Helper method to find by test-class within a found element
    def find_by_test_class_within(element, test_class)
      element.find("[data-test-class='#{test_class}']")
    end

    # Helper method to create has_*? methods for test-ids
    def self.has_test_id_methods(*test_ids)
      test_ids.each do |test_id|
        method_name = test_id.gsub(/[^a-zA-Z0-9_]/, '_').downcase
        define_method("has_#{method_name}?") do
          has_test_id?(test_id)
        end

        define_method("has_no_#{method_name}?") do
          has_no_test_id?(test_id)
        end
      end
    end

    # Helper method to create has_*? methods for test-classes
    def self.has_test_class_methods(*test_classes)
      test_classes.each do |test_class|
        method_name = test_class.gsub(/[^a-zA-Z0-9_]/, '_').downcase
        define_method("has_#{method_name}?") do
          has_test_class?(test_class)
        end

        define_method("has_no_#{method_name}?") do
          has_no_test_class?(test_class)
        end
      end
    end
  end
end
