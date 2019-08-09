# frozen_string_literal: true

require 'rdf/n3'

module RLetters
  module Documents
    module Serializers
      # Convert a document to an RDF record
      #
      # For the moment, we provide only metadata items for the basic Dublin
      # Core elements, and for the Dublin Core
      # ["bibliographicCitation"
      # element.](http://dublincore.org/documents/dc-citation-guidelines/)
      # We also encode an OpenURL reference (using the standard OpenURL
      # namespace), in a second bibliographicCitation element.  The precise way
      # to encode journal articles in DC is in serious flux, but this should
      # provide a reasonable solution.
      class Rdf < Base
        private

        # Return the document as an RDF::Graph object
        #
        # @param [Document] d the document to convert
        # @return [RDF::Graph] the RDF graph
        def to_rdf_graph(doc)
          graph = ::RDF::Graph.new
          node = ::RDF::Node.new

          doc.authors.each do |a|
            name = +''
            name << "#{a.prefix} " if a.prefix
            name << a.last.to_s
            name << " #{a.suffix}" if a.suffix
            name << ", #{a.first}"
            graph << [node, ::RDF::Vocab::DC.creator, name]
          end
          graph << [node, ::RDF::Vocab::DC.issued, doc.year] if doc.year

          citation = +''
          citation << doc.journal if doc.journal
          citation << (doc.volume ? " #{doc.volume}" : ' ')
          citation << "(#{doc.number})" if doc.number
          citation << ", #{doc.pages}" if doc.pages
          citation << ". (#{doc.year})" if doc.year
          graph << [node, ::RDF::Vocab::DC.bibliographicCitation, citation]

          ourl = ::RDF::Literal.new(
            '&' + RLetters::Documents::AsOpenUrl.new(doc).params,
            datatype: ::RDF::URI.new('info:ofi/fmt:kev:mtx:ctx')
          )
          graph << [node, ::RDF::Vocab::DC.bibliographicCitation, ourl]

          graph << [node, ::RDF::Vocab::DC.relation, doc.journal] if doc.journal
          graph << [node, ::RDF::Vocab::DC.title, doc.title] if doc.title
          graph << [node, ::RDF::Vocab::DC.type, 'Journal Article']
          graph << [node, ::RDF::Vocab::DC.identifier, "info:doi/#{doc.doi}"] if doc.doi

          graph
        end
      end
    end
  end
end
