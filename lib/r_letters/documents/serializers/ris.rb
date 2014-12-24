
module RLetters
  module Documents
    module Serializers
      # Convert a document to a RIS record
      class RIS
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
          'RefMan/RIS'
        end

        # Return a URL where information about this serializer can be found
        #
        # @return [String] URL for information about this format
        def self.url
          'http://www.refman.com/support/risformat_intro.asp'
        end

        # Returns this document as a RIS record
        #
        # @api public
        # @return [String] document in RIS format
        # @example Download this document as a ris file
        #   controller.send_data(
        #     RLetters::Documents::Serializers::RIS.new(doc).serialize,
        #     filename: 'export.ris', disposition: 'attachment'
        #   )
        def serialize
          if @doc.is_a? Enumerable
            @doc.map { |d| do_serialize(d) }.join
          else
            do_serialize(@doc)
          end
        end

        private

        # Do the serialization for an individual document
        #
        # @api private
        # @param [Document] doc the document to serialize
        # @return [String] single document serialized to RIS format
        def do_serialize(doc)
          ret  = "TY  - JOUR\n"
          doc.authors.each do |a|
            ret << 'AU  - '
            ret << "#{a.prefix} " if a.prefix
            ret << "#{a.last},#{a.first}"
            ret << ",#{a.suffix}" if a.suffix
            ret << "\n"
          end
          ret << "TI  - #{doc.title}\n" if doc.title
          ret << "PY  - #{doc.year}\n" if doc.year
          ret << "JO  - #{doc.journal}\n" if doc.journal
          ret << "VL  - #{doc.volume}\n" if doc.volume
          ret << "IS  - #{doc.number}\n" if doc.number
          ret << "SP  - #{doc.start_page}\n" if doc.start_page
          ret << "EP  - #{doc.end_page}\n" if doc.end_page
          ret << "ER  - \n"
          ret
        end
      end
    end
  end
end
