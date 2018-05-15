# frozen_string_literal: true

require 'r_letters/documents/serializers/rdf'
require 'rdf/n3'

module RLetters
  module Documents
    module Serializers
      # Convert a document to an RDF/N3 record
      class RDFN3 < RDF
        define_single('RDF/N3',
                      'http://www.w3.org/DesignIssues/Notation3.html') do |doc|
          # Not covered by specs, as we're testing the RDF base class
          # generation in the RDF/XML format instead.
          # :nocov:
          ::RDF::Writer.for(:n3).buffer do |writer|
            writer << if doc.is_a? Enumerable
                        doc.each { |d| to_rdf_graph(d) }
                      else
                        to_rdf_graph(doc)
                      end
          end
          # :nocov:
        end
      end
    end
  end
end
