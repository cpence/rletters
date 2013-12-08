# -*- encoding : utf-8 -*-

module Documents
  module Serializers
    # Convert a document to a MODS XML document
    module MODS
      extend ActiveSupport::Concern

      included do
        # Register this serializer in the Document list
        register_serializer(
          :mods, 'MODS',
          ->(doc) { doc.to_mods.to_xml(indent: 2) },
          'http://www.loc.gov/standards/mods/'
        )
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
      # @return [Nokogiri::XML::Document] document as a MODS record
      # @example Write out this document as MODS XML
      #   output = ''
      #   doc.to_mods.write output
      def to_mods(include_namespace = true)
        doc = Nokogiri::XML::Document.new
        mods = Nokogiri::XML::Node.new('mods', doc)
        doc.add_child(mods)

        if include_namespace
          mods.add_namespace_definition(nil, 'http://www.loc.gov/mods/v3')
          mods.add_namespace_definition('xlink', 'http://www.w3.org/1999/xlink')
          mods.add_namespace_definition('xsi', 'http://www.w3.org/2001/XMLSchema-instance')
          mods['xsi:schemaLocation'] = 'http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-0.xsd'
        end

        mods['version'] = '3.0'
        mods['ID'] = 'rletters_' + html_uid

        if title.present?
          title_info = Nokogiri::XML::Node.new('titleInfo', doc)
          mods.add_child(title_info)

          title_elt = Nokogiri::XML::Node.new('title', doc)
          title_info.add_child(title_elt)

          title_elt.content = title
        end

        if formatted_author_list.present?
          formatted_author_list.each do |a|
            name = Nokogiri::XML::Node.new('name', doc)
            mods.add_child(name)

            name['type'] = 'personal'

            first_name_elt = Nokogiri::XML::Node.new('namePart', doc)
            name.add_child(first_name_elt)
            first_name_elt.content = a.first
            first_name_elt['type'] = 'given'

            last_name = ''
            last_name << " #{a.von}" if a.von.present?
            last_name << a.last
            last_name << ", #{a.suffix}" if a.suffix.present?
            last_name_elt = Nokogiri::XML::Node.new('namePart', doc)
            name.add_child(last_name_elt)
            last_name_elt.content = last_name
            last_name_elt['type'] = 'family'

            role = Nokogiri::XML::Node.new('role', doc)
            name.add_child(role)
            role_term = Nokogiri::XML::Node.new('roleTerm', doc)
            role.add_child(role_term)
            role_term.content = 'author'
            role_term['type'] = 'text'
            role_term['authority'] = 'marcrelator'
          end
        end

        type_of_resource = Nokogiri::XML::Node.new('typeOfResource', doc)
        mods.add_child(type_of_resource)
        type_of_resource.content = 'text'

        article_genre = Nokogiri::XML::Node.new('genre', doc)
        mods.add_child(article_genre)
        article_genre.content = 'article'

        article_origin_info = Nokogiri::XML::Node.new('originInfo', doc)
        mods.add_child(article_origin_info)
        article_issuance = Nokogiri::XML::Node.new('issuance', doc)
        article_origin_info.add_child(article_issuance)
        article_issuance.content = 'monographic'
        if year.present?
          date_issued = Nokogiri::XML::Node.new('dateIssued', doc)
          article_origin_info.add_child(date_issued)
          date_issued.content = year
        end

        related_item = Nokogiri::XML::Node.new('relatedItem', doc)
        mods.add_child(related_item)
        related_item['type'] = 'host'

        if journal.present?
          title_info = Nokogiri::XML::Node.new('titleInfo', doc)
          related_item.add_child(title_info)
          title_info['type'] = 'abbreviated'

          title_elt = Nokogiri::XML::Node.new('title', doc)
          title_info.add_child(title_elt)
          title_elt.content = journal
        end

        journal_origin_info = Nokogiri::XML::Node.new('originInfo', doc)
        related_item.add_child(journal_origin_info)
        journal_issuance = Nokogiri::XML::Node.new('issuance', doc)
        journal_origin_info.add_child(journal_issuance)
        journal_issuance.content = 'continuing'
        if year.present?
          date_issued = Nokogiri::XML::Node.new('dateIssued', doc)
          journal_origin_info.add_child(date_issued)
          date_issued.content = year
        end

        journal_genre_1 = Nokogiri::XML::Node.new('genre', doc)
        related_item.add_child(journal_genre_1)
        journal_genre_1.content = 'periodical'
        journal_genre_1['authority'] = 'marcgt'
        journal_genre_2 = Nokogiri::XML::Node.new('genre', doc)
        related_item.add_child(journal_genre_2)
        journal_genre_2.content = 'academic journal'

        part = Nokogiri::XML::Node.new('part', doc)
        related_item.add_child(part)
        if volume.present?
          detail = Nokogiri::XML::Node.new('detail', doc)
          part.add_child(detail)
          detail['type'] = 'volume'
          number_elt = Nokogiri::XML::Node.new('number', doc)
          detail.add_child(number_elt)
          number_elt.content = volume
        end

        if number.present?
          detail = Nokogiri::XML::Node.new('detail', doc)
          part.add_child(detail)
          detail['type'] = 'issue'
          number_elt = Nokogiri::XML::Node.new('number', doc)
          detail.add_child(number_elt)
          number_elt.content = number
          caption = Nokogiri::XML::Node.new('caption', doc)
          detail.add_child(caption)
          caption.content = 'no.'
        end

        if pages.present?
          extent = Nokogiri::XML::Node.new('extent', doc)
          part.add_child(extent)
          extent['unit'] = 'page'
          if start_page.present?
            start_elt = Nokogiri::XML::Node.new('start', doc)
            extent.add_child(start_elt)
            start_elt.content = start_page
          end
          if end_page.present?
            end_elt = Nokogiri::XML::Node.new('end', doc)
            extent.add_child(end_elt)
            end_elt.content = end_page
          end
        end

        if year.present?
          date = Nokogiri::XML::Node.new('date', doc)
          part.add_child(date)
          date.content = year
        end

        if doi.present?
          identifier = Nokogiri::XML::Node.new('identifier', doc)
          mods.add_child(identifier)
          identifier['type'] = 'doi'
          identifier.content = doi
        end

        doc
      end
    end
  end
end

# Ruby's standard Array class
class Array
  # Convert this array (of Document objects) to a MODS collection
  #
  # Only will work on arrays that consist entirely of Document objects, will
  # raise an ArgumentError otherwise.
  #
  # @api public
  # @return [Nokogiri::XML::Document] array of documents as MODS collection
  #   document
  # @example Save an array of documents in MODS format to stdout
  #   doc_array = Solr::Connection.search(...).documents
  #   puts doc_array.to_mods.to_xml(indent: 2)
  def to_mods
    each do |x|
      fail ArgumentError, 'No to_mods method for array element' unless x.respond_to? :to_mods
    end

    doc = Nokogiri::XML::Document.new
    coll = Nokogiri::XML::Node.new('modsCollection', doc)
    coll.add_namespace_definition(nil, 'http://www.loc.gov/mods/v3')
    coll.add_namespace_definition('xlink', 'http://www.w3.org/1999/xlink')
    coll.add_namespace_definition('xsi', 'http://www.w3.org/2001/XMLSchema-instance')
    coll['xsi:schemaLocation'] = 'http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-0.xsd'
    doc.root = coll

    map { |d| coll.add_child(d.to_mods(false).root) }

    doc
  end
end
