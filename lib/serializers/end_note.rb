# -*- encoding : utf-8 -*-

module Serializers

  # Convert a document to an EndNote record
  module EndNote

    # Register this serializer in the Document list
    def self.included(base)
      base.register_serializer(
        :endnote, 'EndNote',
        ->(doc) { doc.to_endnote },
        'http://auditorymodels.org/jba/bibs/NetBib/Tools/bp-0.2.97/doc/endnote.html'
      )
    end

    # Returns this document as an EndNote record
    #
    # @api public
    # @return [String] document in EndNote format
    # @example Download this document as a enw file
    #   controller.send_data doc.to_endnote, filename: 'export.enw',
    #                        disposition: 'attachment'
    def to_endnote
      ret  = "%0 Journal Article\n"
      if formatted_author_list && formatted_author_list.count
        formatted_author_list.each do |a|
          ret << "%A #{a.last}, #{a.first}"
          ret << " #{a.von}" if a.von.present?
          ret << ", #{a.suffix}" if a.suffix.present?
          ret << "\n"
        end
      end
      ret << "%T #{title}\n" if title.present?
      ret << "%D #{year}\n" if year.present?
      ret << "%J #{journal}\n" if journal.present?
      ret << "%V #{volume}\n" if volume.present?
      ret << "%N #{number}\n" if number.present?
      ret << "%P #{pages}\n" if pages.present?
      ret << "%M #{doi}\n" if doi.present?
      ret << "\n"
      ret
    end
  end
end

# Ruby's standard Array class
class Array
  # Convert this array (of Document objects) to an EndNote collection
  #
  # Only will work on arrays that consist entirely of Document objects, will
  # raise an ArgumentError otherwise.
  #
  # @api public
  # @return [String] array of documents as EndNote collection
  # @example Save an array of documents in EndNote format to stdout
  #   doc_array = Solr::Connection.search(...).documents
  #   $stdout.write(doc_array.to_endnote)
  def to_endnote
    each do |x|
      fail ArgumentError, 'No to_endnote method for array element' unless x.respond_to? :to_endnote
    end

    map { |x| x.to_endnote }.join
  end
end
