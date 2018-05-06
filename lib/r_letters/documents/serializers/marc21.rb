# frozen_string_literal: true
require 'r_letters/documents/serializers/marc_record'

module RLetters
  module Documents
    module Serializers
      # Convert a document to a MARC21 transmission record
      class MARC21 < MARCRecord
        define_single(:marc, 'MARC21', 'http://www.loc.gov/marc/') do |doc|
          to_marc_record(doc).to_marc
        end
      end
    end
  end
end
