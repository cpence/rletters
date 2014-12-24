
module RLetters
  module Documents
    module Serializers
      # Available MIME types for serialization
      MIME_TYPES = [:bibtex, :endnote, :marc, :json, :marcxml,
                    :mods, :n3, :rdf, :ris]

      # Find the serializer for serializing to the given format
      #
      # @api public
      # @param format [Symbol] the format to serialize to
      # @return [Class] an appropriate serializer class
      def self.for(format)
        case format.to_sym
        when :bibtex
          BibTex
        when :endnote
          EndNote
        when :marc
          MARC21
        when :json
          MARCJSON
        when :marcxml
          MARCXML
        when :mods
          MODS
        when :n3
          RDFN3
        when :rdf
          RDFXML
        when :ris
          RIS
        else
          fail ArgumentError, 'Invalid format passed to serializer factory'
        end
      end
    end
  end
end
