# frozen_string_literal: true

module RLetters
  module Documents
    module Serializers
      module CommonTests
        def test_class_methods_work
          class_name = self.class.name.sub('Test', '')
          klass = class_name.constantize

          assert_kind_of String, klass.format
          assert_kind_of String, klass.url
        end
      end
    end
  end
end
