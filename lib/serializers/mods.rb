# -*- encoding : utf-8 -*-
module Serializers

  # Convert a document to a MODS XML document
  module MODS

    # Register this serializer in the Document list
    def self.included(base)
      base.register_serializer(:mods, 'MODS', lambda { |doc|
          xml = doc.to_mods
          ret = ''
          xml.write(ret, 2)
          ret }, 'http://www.loc.gov/standards/mods/')
    end

    # Returns this document as a MODS XML document
    #
    # By default, this will include the XML namespace declarations in the
    # root +mods+ element, making this document suitable to be saved
    # standalone.  Pass +false+ to include_namespace to get a plain root
    # element without namespaces, suitable for inclusion in a
    # +modsCollection+.
    #
    # @api public
    # @param [Boolean] include_namespace if false, put no namespace in the
    #   root element
    # @return [REXML::Document] document as a MODS record
    # @example Write out this document as MODS XML
    #   output = ''
    #   doc.to_mods.write output
    def to_mods(include_namespace = true)
      mods = REXML::Element.new 'mods'
      if include_namespace
        mods.add_namespace "xlink", "http://www.w3.org/1999/xlink"
        mods.add_namespace "xsi", "http://www.w3.org/2001/XMLSchema-instance"
        mods.add_namespace "http://www.loc.gov/mods/v3"
        mods.attributes['xsi:schemaLocation'] = "http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-0.xsd"
      end

      mods.attributes['version'] = '3.0'
      mods.attributes['ID'] = 'rletters_' + shasum

      unless title.blank?
        title_info = mods.add_element 'titleInfo'
        title_elt = title_info.add_element 'title'
        title_elt.text = title
      end

      unless formatted_author_list.nil? || formatted_author_list.count == 0
        formatted_author_list.each do |a|
          name = mods.add_element 'name'
          name.attributes['type'] = 'personal'

          first_name_elt = name.add_element 'namePart'
          first_name_elt.text = a.first
          first_name_elt.attributes['type'] = 'given'

          last_name = ''
          last_name << " #{a.von}" unless a.von.blank?
          last_name << a.last
          last_name << ", #{a.suffix}" unless a.suffix.blank?
          last_name_elt = name.add_element 'namePart'
          last_name_elt.text = last_name
          last_name_elt.attributes['type'] = 'family'

          role = name.add_element 'role'
          roleTerm = role.add_element 'roleTerm'
          roleTerm.text = 'author'
          roleTerm.attributes['type'] = 'text'
          roleTerm.attributes['authority'] = 'marcrelator'
        end
      end

      type_of_resource = mods.add_element 'typeOfResource'
      type_of_resource.text = 'text'

      article_genre = mods.add_element 'genre'
      article_genre.text = 'article'

      article_origin_info = mods.add_element 'originInfo'
      article_issuance = article_origin_info.add_element 'issuance'
      article_issuance.text = 'monographic'
      unless year.blank?
        date_issued = article_origin_info.add_element 'dateIssued'
        date_issued.text = year
      end

      related_item = mods.add_element 'relatedItem'
      related_item.attributes['type'] = 'host'

      unless journal.blank?
        title_info = related_item.add_element 'titleInfo'
        title_info.attributes['type'] = 'abbreviated'

        title_elt = title_info.add_element 'title'
        title_elt.text = journal
      end

      journal_origin_info = related_item.add_element 'originInfo'
      journal_issuance = journal_origin_info.add_element 'issuance'
      journal_issuance.text = 'continuing'
      unless year.blank?
        date_issued = journal_origin_info.add_element 'dateIssued'
        date_issued.text = year
      end

      journal_genre_1 = related_item.add_element 'genre'
      journal_genre_1.text = 'periodical'
      journal_genre_1.attributes['authority'] = 'marcgt'
      journal_genre_2 = related_item.add_element 'genre'
      journal_genre_2.text = 'academic journal'

      part = related_item.add_element 'part'
      unless volume.blank?
        detail = part.add_element 'detail'
        detail.attributes['type'] = 'volume'
        number_elt = detail.add_element 'number'
        number_elt.text = volume
      end

      unless number.blank?
        detail = part.add_element 'detail'
        detail.attributes['type'] = 'issue'
        number_elt = detail.add_element 'number'
        number_elt.text = number
        caption = detail.add_element 'caption'
        caption.text = 'no.'
      end

      unless pages.blank?
        extent = part.add_element 'extent'
        extent.attributes['unit'] = 'page'
        unless start_page.blank?
          start = extent.add_element 'start'
          start.text = start_page
        end
        unless end_page.blank?
          end_elt = extent.add_element 'end'
          end_elt.text = end_page
        end
      end

      unless year.blank?
        date = part.add_element 'date'
        date.text = year
      end

      unless doi.blank?
        identifier = mods.add_element 'identifier'
        identifier.attributes['type'] = 'doi'
        identifier.text = doi
      end

      doc = REXML::Document.new
      doc << REXML::XMLDecl.new
      doc << mods
      doc
    end
  end
end

class Array
  # Convert this array (of Document objects) to a MODS collection
  #
  # Only will work on arrays that consist entirely of Document objects, will
  # raise an ArgumentError otherwise.
  #
  # @api public
  # @return [REXML::Document] array of documents as MODS collection document
  # @example Save an array of documents in MODS format to stdout
  #   doc_array = Document.find_all_by_solr_query(...)
  #   doc_array.to_mods.write($stdout, 2)
  def to_mods
    self.each do |x|
      raise ArgumentError, 'No to_mods method for array element' unless x.respond_to? :to_mods
    end

    coll = REXML::Element.new 'modsCollection'
    coll.add_namespace "xlink", "http://www.w3.org/1999/xlink"
    coll.add_namespace "xsi", "http://www.w3.org/2001/XMLSchema-instance"
    coll.add_namespace "http://www.loc.gov/mods/v3"
    coll.attributes['xsi:schemaLocation'] = "http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-0.xsd"

    self.map { |d| coll.add(d.to_mods(false).root) }

    ret = REXML::Document.new
    ret << REXML::XMLDecl.new
    ret << coll

    ret
  end
end
