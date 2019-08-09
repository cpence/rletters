# frozen_string_literal: true

module RLetters
  module Documents
    module Serializers
      # Convert a document to a MARC21 transmission record
      class Marc21 < MarcRecord
        define_single('MARC21', 'http://www.loc.gov/marc/') do |doc|
          to_marc_record(doc).to_marc
        end
      end
    end
  end
end
