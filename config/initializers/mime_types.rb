# frozen_string_literal: true

# Add new mime types for use in respond_to blocks:
Mime::Type.register 'application/marc', :marc, [], %w(mrc 001)
Mime::Type.register 'application/marcxml+xml', :marcxml
Mime::Type.register 'application/x-bibtex', :bibtex, [], ['bib']
Mime::Type.register 'application/x-endnote-refer', :endnote, [], ['enw']
Mime::Type.register 'application/x-research-info-systems', :ris
Mime::Type.register 'application/mods+xml', :mods
Mime::Type.register 'application/rdf+xml', :rdf
Mime::Type.register 'text/rdf+n3', :n3
Mime::Type.register 'application/graphml+xml', :graphml
Mime::Type.register 'image/x-icon', :ico
