# frozen_string_literal: true

require 'r_letters/documents/serializers/marc_record'

module RLetters
  module Documents
    module Serializers
      # Convert a document to a MARC record
      class MARCJSON < MARCRecord
        # This isn't really a single, but we need separate array support that's
        # not the usual.
        define_single(:json, 'MARC-in-JSON',
                      'http://www.oclc.org/developer/content/marc-json-draft-2010-03-11') do |doc|
          if doc.is_a? Enumerable
            doc.map { |d| to_marc_record(d).to_hash }.to_json
          else
            to_marc_record(doc).to_hash.to_json
          end
        end
      end
    end
  end
end
