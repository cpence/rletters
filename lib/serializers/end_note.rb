# -*- encoding : utf-8 -*-

module Serializers

  # Convert a document to an EndNote record
  module EndNote

    # Register this serializer in the Document list
    def self.included(base)
      base.register_serializer(:endnote, 'EndNote', lambda { |doc| doc.to_endnote },
        'http://auditorymodels.org/jba/bibs/NetBib/Tools/bp-0.2.97/doc/endnote.html')
    end

    # Returns this document as an EndNote record
    #
    # @api public
    # @return [String] document in EndNote format
    # @example Download this document as a enw file
    #   controller.send_data doc.to_endnote, :filename => 'export.enw', :disposition => 'attachment'
    def to_endnote
      ret  = "%0 Journal Article\n"
      if formatted_author_list && formatted_author_list.count
        formatted_author_list.each do |a|
          ret << "%A #{a.last}, #{a.first}"
          ret << " #{a.von}" unless a.von.blank?
          ret << ", #{a.suffix}" unless a.suffix.blank?
          ret << "\n"
        end
      end
      ret << "%T #{title}\n" unless title.blank?
      ret << "%D #{year}\n" unless year.blank?
      ret << "%J #{journal}\n" unless journal.blank?
      ret << "%V #{volume}\n" unless volume.blank?
      ret << "%N #{number}\n" unless number.blank?
      ret << "%P #{pages}\n" unless pages.blank?
      ret << "%M #{doi}\n" unless doi.blank?
      ret << "\n"
      ret
    end
  end
end

class Array
  # Convert this array (of Document objects) to an EndNote collection
  #
  # Only will work on arrays that consist entirely of Document objects, will
  # raise an ArgumentError otherwise.
  #
  # @api public
  # @return [String] array of documents as EndNote collection
  # @example Save an array of documents in EndNote format to stdout
  #   doc_array = Document.find_all_by_solr_query(...)
  #   $stdout.write(doc_array.to_endnote)
  def to_endnote
    self.each do |x|
      raise ArgumentError, 'No to_endnote method for array element' unless x.respond_to? :to_endnote
    end

    self.map { |x| x.to_endnote }.join
  end
end
