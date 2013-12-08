# -*- encoding : utf-8 -*-

module Documents
  # Methods for registering serializers with the +Document+ class
  module SerializationBase
    extend ActiveSupport::Concern

    module ClassMethods
      # Registration for all serializers
      #
      # This variable is a hash of hashes.  For its format, see the documentation
      # for register_serializer.
      #
      # @api public
      # @return [Hash] the serializer registry
      # @example See if there is a serializer loaded for JSON
      #   Document.serializers.has_key? :json
      attr_accessor :serializers

      # Register a serializer
      #
      # @api public
      # @return [undefined]
      # @param [Symbol] key the MIME type key for this serializer, as defined
      #   in config/initializers/mime_types.rb
      # @param [String] name the human-readable name of this serializer format
      # @param [Proc] method a method which accepts a Document object as a
      #   parameter and returns the serialized document as a String
      # @param [String] docs a URL pointing to documentation for this method
      # @example Register a serializer for JSON
      #   Document.register_serializer (:json,
      #                                 'JSON',
      #                                 ->(doc) { doc.to_json },
      #                                 'http://www.json.org/')
      def register_serializer(key, name, method, docs)
        Document.serializers ||= {}
        Document.serializers[key] = { name: name, method: method, docs: docs }
      end
    end
  end

  # Code for serializing a +Document+ to different output/citation formats
  module Serialization
    extend ActiveSupport::Concern

    include SerializationBase
    include Serializers::BibTex
    include Serializers::CSL
    include Serializers::EndNote
    include Serializers::MARC
    include Serializers::MODS
    include Serializers::RDF
    include Serializers::RIS
    include Serializers::OpenURL
  end
end
