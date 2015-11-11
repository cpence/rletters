
module RLetters
  module Documents
    # Serialization code for +Document+ objects
    #
    # This module contains helpers intended to be included by the +Document+
    # model, which allow the document to be converted to any one of a number of
    # export formats.
    module Serializers
      # Code common to all serializers
      class Base
        # Create a serializer that can serialize only individual documents
        #
        # @param [String] format The name of the serializer
        # @param [String] url A URL for information about this format
        # @return [void]
        def self.define_single(format, url, &block)
          define_common_methods(format, url)

          define_method :serialize do
            instance_exec instance_variable_get(:@doc), &block
          end
        end

        # Create a serializer that can serialize documents or arrays
        #
        # @param [String] format The name of the serializer
        # @param [String] url A URL for information about this format
        # @return [void]
        def self.define_array(format, url, &block)
          define_common_methods(format, url)

          define_method :serialize do
            docs = instance_variable_get(:@doc)
            if docs.is_a? Enumerable
              docs.map { |d| do_serialize(d) }.join
            else
              do_serialize(docs)
            end
          end

          private

          define_method :do_serialize do |doc|
            instance_exec doc, &block
          end
        end

        private

        # Define the common `.format` and `.url` class methods, as well as
        # the `#initialize` class method.
        #
        # @param [String] format The name of the serializer
        # @param [String] url A URL for information about this format
        # @return [void]
        def self.define_common_methods(format, url)
          singleton_class.instance_eval do
            define_method :format do
              format
            end

            define_method :url do
              url
            end
          end

          define_method :initialize do |doc|
            instance_variable_set(:@doc, doc)
          end
        end
      end
    end
  end
end
