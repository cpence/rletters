require 'r_letters/documents/serializers/marc_record'

module RLetters
  module Documents
    module Serializers
      # Convert a document to a MODS XML document
      class MODS < Base
        define_single(:mods, 'MODS',
                      'http://www.loc.gov/standards/mods/') do |docs|
          if docs.is_a? Enumerable
            doc = Nokogiri::XML::Document.new
            coll = Nokogiri::XML::Node.new('modsCollection', doc)
            coll.add_namespace_definition(nil, 'http://www.loc.gov/mods/v3')
            coll.add_namespace_definition('xlink', 'http://www.w3.org/1999/xlink')
            coll.add_namespace_definition('xsi', 'http://www.w3.org/2001/XMLSchema-instance')
            coll['xsi:schemaLocation'] = 'http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-0.xsd'
            doc.root = coll

            docs.map { |d| coll.add_child(to_mods(d, false).root) }

            doc.to_xml(indent: 2)
          else
            to_mods(docs, true).to_xml(indent: 2)
          end
        end

        private

        # Do the serialization for an individual document
        #
        # @param [Document] doc the document to serialize
        # @param [Boolean] include_namespace if false, put no namespace in the
        #   root element
        # @return [Nokogiri::XML::Node] single document serialized to MODS
        def to_mods(doc, include_namespace = true)
          xml_doc = Nokogiri::XML::Document.new
          mods = Nokogiri::XML::Node.new('mods', xml_doc)
          xml_doc.add_child(mods)

          if include_namespace
            mods.add_namespace_definition(nil, 'http://www.loc.gov/mods/v3')
            mods.add_namespace_definition('xlink', 'http://www.w3.org/1999/xlink')
            mods.add_namespace_definition('xsi', 'http://www.w3.org/2001/XMLSchema-instance')
            mods['xsi:schemaLocation'] = 'http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-0.xsd'
          end

          mods['version'] = '3.0'
          mods['ID'] = 'rletters_' + doc.uid.gsub(/[^0-9a-zA-Z\-_]/, '_')

          if doc.title
            title_info = Nokogiri::XML::Node.new('titleInfo', xml_doc)
            mods.add_child(title_info)

            title_elt = Nokogiri::XML::Node.new('title', xml_doc)
            title_info.add_child(title_elt)

            title_elt.content = doc.title
          end

          doc.authors.each do |a|
            name = Nokogiri::XML::Node.new('name', xml_doc)
            mods.add_child(name)

            name['type'] = 'personal'

            first_name_elt = Nokogiri::XML::Node.new('namePart', xml_doc)
            name.add_child(first_name_elt)
            first_name_elt.content = a.first
            first_name_elt['type'] = 'given'

            last_name = ''
            last_name << " #{a.prefix}" if a.prefix
            last_name << a.last
            last_name << ", #{a.suffix}" if a.suffix
            last_name_elt = Nokogiri::XML::Node.new('namePart', xml_doc)
            name.add_child(last_name_elt)
            last_name_elt.content = last_name
            last_name_elt['type'] = 'family'

            role = Nokogiri::XML::Node.new('role', xml_doc)
            name.add_child(role)
            role_term = Nokogiri::XML::Node.new('roleTerm', xml_doc)
            role.add_child(role_term)
            role_term.content = 'author'
            role_term['type'] = 'text'
            role_term['authority'] = 'marcrelator'
          end

          type_of_resource = Nokogiri::XML::Node.new('typeOfResource', xml_doc)
          mods.add_child(type_of_resource)
          type_of_resource.content = 'text'

          article_genre = Nokogiri::XML::Node.new('genre', xml_doc)
          mods.add_child(article_genre)
          article_genre.content = 'article'

          article_origin_info = Nokogiri::XML::Node.new('originInfo', xml_doc)
          mods.add_child(article_origin_info)
          article_issuance = Nokogiri::XML::Node.new('issuance', xml_doc)
          article_origin_info.add_child(article_issuance)
          article_issuance.content = 'monographic'
          if doc.year
            date_issued = Nokogiri::XML::Node.new('dateIssued', xml_doc)
            article_origin_info.add_child(date_issued)
            date_issued.content = doc.year
          end

          related_item = Nokogiri::XML::Node.new('relatedItem', xml_doc)
          mods.add_child(related_item)
          related_item['type'] = 'host'

          if doc.journal
            title_info = Nokogiri::XML::Node.new('titleInfo', xml_doc)
            related_item.add_child(title_info)
            title_info['type'] = 'abbreviated'

            title_elt = Nokogiri::XML::Node.new('title', xml_doc)
            title_info.add_child(title_elt)
            title_elt.content = doc.journal
          end

          journal_origin_info = Nokogiri::XML::Node.new('originInfo', xml_doc)
          related_item.add_child(journal_origin_info)
          journal_issuance = Nokogiri::XML::Node.new('issuance', xml_doc)
          journal_origin_info.add_child(journal_issuance)
          journal_issuance.content = 'continuing'
          if doc.year
            date_issued = Nokogiri::XML::Node.new('dateIssued', xml_doc)
            journal_origin_info.add_child(date_issued)
            date_issued.content = doc.year
          end

          journal_genre_1 = Nokogiri::XML::Node.new('genre', xml_doc)
          related_item.add_child(journal_genre_1)
          journal_genre_1.content = 'periodical'
          journal_genre_1['authority'] = 'marcgt'
          journal_genre_2 = Nokogiri::XML::Node.new('genre', xml_doc)
          related_item.add_child(journal_genre_2)
          journal_genre_2.content = 'academic journal'

          part = Nokogiri::XML::Node.new('part', xml_doc)
          related_item.add_child(part)
          if doc.volume
            detail = Nokogiri::XML::Node.new('detail', xml_doc)
            part.add_child(detail)
            detail['type'] = 'volume'
            number_elt = Nokogiri::XML::Node.new('number', xml_doc)
            detail.add_child(number_elt)
            number_elt.content = doc.volume
          end

          if doc.number
            detail = Nokogiri::XML::Node.new('detail', xml_doc)
            part.add_child(detail)
            detail['type'] = 'issue'
            number_elt = Nokogiri::XML::Node.new('number', xml_doc)
            detail.add_child(number_elt)
            number_elt.content = doc.number
            caption = Nokogiri::XML::Node.new('caption', xml_doc)
            detail.add_child(caption)
            caption.content = 'no.'
          end

          if doc.pages
            extent = Nokogiri::XML::Node.new('extent', xml_doc)
            part.add_child(extent)
            extent['unit'] = 'page'
            if doc.start_page
              start_elt = Nokogiri::XML::Node.new('start', xml_doc)
              extent.add_child(start_elt)
              start_elt.content = doc.start_page
            end
            if doc.end_page
              end_elt = Nokogiri::XML::Node.new('end', xml_doc)
              extent.add_child(end_elt)
              end_elt.content = doc.end_page
            end
          end

          if doc.year
            date = Nokogiri::XML::Node.new('date', xml_doc)
            part.add_child(date)
            date.content = doc.year
          end

          if doc.doi
            identifier = Nokogiri::XML::Node.new('identifier', xml_doc)
            mods.add_child(identifier)
            identifier['type'] = 'doi'
            identifier.content = doc.doi
          end

          xml_doc
        end
      end
    end
  end
end
