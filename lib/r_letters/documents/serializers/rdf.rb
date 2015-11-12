require 'r_letters/documents/as_open_url'
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
      class RDF < Base
        private

        # Return the document as an RDF::Graph object
        #
        # @param [Document] d the document to convert
        # @return [RDF::Graph] the RDF graph
        def to_rdf_graph(d)
          graph = ::RDF::Graph.new
          doc = ::RDF::Node.new

          d.authors.each do |a|
            name = ''
            name << "#{a.prefix} " if a.prefix
            name << "#{a.last}"
            name << " #{a.suffix}" if a.suffix
            name << ", #{a.first}"
            graph << [doc, ::RDF::Vocab::DC.creator, name]
          end
          graph << [doc, ::RDF::Vocab::DC.issued, d.year] if d.year

          citation = "#{d.journal}" if d.journal
          citation << (d.volume ? " #{d.volume}" : ' ')
          citation << "(#{d.number})" if d.number
          citation << ", #{d.pages}" if d.pages
          citation << ". (#{d.year})" if d.year
          graph << [doc, ::RDF::Vocab::DC.bibliographicCitation, citation]

          ourl = ::RDF::Literal.new(
            '&' + RLetters::Documents::AsOpenURL.new(d).params,
            datatype: ::RDF::URI.new('info:ofi/fmt:kev:mtx:ctx')
          )
          graph << [doc, ::RDF::Vocab::DC.bibliographicCitation, ourl]

          graph << [doc, ::RDF::Vocab::DC.relation, d.journal] if d.journal
          graph << [doc, ::RDF::Vocab::DC.title, d.title] if d.title
          graph << [doc, ::RDF::Vocab::DC.type, 'Journal Article']
          graph << [doc, ::RDF::Vocab::DC.identifier, "info:doi/#{d.doi}"] if d.doi

          graph
        end
      end
    end
  end
end
