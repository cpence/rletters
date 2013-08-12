# -*- encoding : utf-8 -*-

module Serializers

  # Convert a document to a RIS record
  module RIS

    # Register this serializer in the Document list
    def self.included(base)
      base.register_serializer(
        :ris, 'RefMan/RIS',
        ->(doc) { doc.to_ris },
        'http://www.refman.com/support/risformat_intro.asp'
      )
    end

    # Returns this document as a RIS record
    #
    # @api public
    # @return [String] document in RIS format
    # @example Download this document as a ris file
    #   controller.send_data doc.to_ris, filename: 'export.ris', disposition:
    #                        'attachment'
    def to_ris
      ret  = "TY  - JOUR\n"
      unless formatted_author_list.nil?
        formatted_author_list.each do |a|
          ret << 'AU  - '
          ret << "#{a.von} " unless a.von.blank?
          ret << "#{a.last},#{a.first}"
          ret << ",#{a.suffix}" unless a.suffix.blank?
          ret << "\n"
        end
      end
      ret << "TI  - #{title}\n" unless title.blank?
      ret << "PY  - #{year}\n" unless year.blank?
      ret << "JO  - #{journal}\n" unless journal.blank?
      ret << "VL  - #{volume}\n" unless volume.blank?
      ret << "IS  - #{number}\n" unless number.blank?
      ret << "SP  - #{start_page}\n" unless start_page.blank?
      ret << "EP  - #{end_page}\n" unless end_page.blank?
      ret << "ER  - \n"
      ret
    end
  end
end

# Ruby's standard Array class
class Array
  # Convert this array (of Document objects) to a RIS collection
  #
  # Only will work on arrays that consist entirely of Document objects, will
  # raise an ArgumentError otherwise.
  #
  # @api public
  # @return [String] array of documents as RIS collection
  # @example Save an array of documents in RIS format to stdout
  #   doc_array = Solr::Connection.find(...).documents
  #   $stdout.write(doc_array.to_ris)
  def to_ris
    each do |x|
      fail ArgumentError, 'No to_ris method for array element' unless x.respond_to? :to_ris
    end

    map { |x| x.to_ris }.join
  end
end
