# -*- encoding : utf-8 -*-

module RLetters
  module Documents
    module Serializers
      # Convert a document to an EndNote record
      class EndNote
        # Create a serializer
        #
        # @api public
        # @param document_or_array [Document Array<Document>] a document or
        #   array of documents to serialize
        def initialize(document_or_array)
          @doc = document_or_array
        end

        # Return the user-friendly name of the serializer
        #
        # @return [String] name of the serializer
        def self.format
          'EndNote'
        end

        # Return a URL where information about this serializer can be found
        #
        # @return [String] URL for information about this format
        def self.url
          'http://auditorymodels.org/jba/bibs/NetBib/Tools/bp-0.2.97/doc/endnote.html'
        end

        # Returns this document as an EndNote record
        #
        # @api public
        # @return [String] document in EndNote format
        # @example Download this document as a enw file
        #   controller.send_data(
        #     RLetters::Documents::Serializers::EndNote.new(doc).serialize,
        #     filename: 'export.enw', disposition: 'attachment'
        #   )
        def serialize
          if @doc.is_a? Enumerable
            @doc.map { |d| do_serialize(d) }.join
          else
            do_serialize(@doc)
          end
        end

        private

        # :nodoc:
        def do_serialize(doc)
          ret  = "%0 Journal Article\n"
          doc.authors.each do |a|
            ret << "%A #{a.last}, #{a.first}"
            ret << " #{a.prefix}" if a.prefix
            ret << ", #{a.suffix}" if a.suffix
            ret << "\n"
          end
          ret << "%T #{doc.title}\n" if doc.title
          ret << "%D #{doc.year}\n" if doc.year
          ret << "%J #{doc.journal}\n" if doc.journal
          ret << "%V #{doc.volume}\n" if doc.volume
          ret << "%N #{doc.number}\n" if doc.number
          ret << "%P #{doc.pages}\n" if doc.pages
          ret << "%M #{doc.doi}\n" if doc.doi
          ret << "\n"
          ret
        end
      end
    end
  end
end
