# -*- encoding : utf-8 -*-

# Representation of a document in the Solr database
#
# This class provides an ActiveRecord-like model object for documents hosted in
# the RLetters Solr backend.  It abstracts both single-document retrieval and
# document searching in class-level methods, and access to the data provided by
# Solr in instance-level methods and attributes.
#
# @!attribute [r] shasum
#   @raise [RecordInvalid] if the SHA-1 checksum is missing (validates
#     :presence)
#   @raise [RecordInvalid] if the SHA-1 checksum is not 40 characters
#     (validates :length)
#   @raise [RecordInvalid] if the SHA-1 checksum contains invalid characters
#     (validates :format)
#   @return [String] the SHA-1 checksum of this document
# @!attribute [r] doi
#   @return [String] the DOI (Digital Object Identifier) of this document
#
# @!attribute [r] license
#   @return [String] the human-readable name of the document's license
# @!attribute [r] license_url
#   @return [String] a URL referencing the document's license terms
#
# @!attribute [r] authors
#   @return [String] the document's authors, in a comma-delimited list
# @!attribute [r] author_list
#   @return [Array<String>] the document's authors, in an array
# @!attribute [r] formatted_author_list
#   @return [Array<Hash>] the document's authors, split into name parts, in
#     an array
#
# @!attribute [r] title
#   @return [String] the title of this document
# @!attribute [r] journal
#   @return [String] the journal in which this document was published
# @!attribute [r] year
#   @return [String] the year in which this document was published
# @!attribute [r] volume
#   @return [String] the journal volume number in which this document was
#     published
# @!attribute [r] number
#   @return [String] the journal issue number in which this document was
#     published
# @!attribute [r] pages
#   @return [String] the page numbers in the journal of this document, in the
#     format 'start-end'
# @!attribute [r] fulltet
#   @return [String] the full text of this document.  May be +nil+ if the query
#     type used to retrieve the document does not provide the full text
#
# @!attribute [r] term_vectors
#   Term vectors for this document
#
#   The Solr server returns a list of information for each term in every
#   document.  The following data is provided (based on Solr server
#   configuration):
#
#   - +:tf+, term frequency: the number of times this term appears in
#     the given document
#   - +:offsets+, term offsets: the start and end character offsets for
#     this word within +fulltext+.  Note that these offsets can be
#     complicated by string encoding issues, be careful when using them!
#   - +:positions+, term positions: the position of this word (in
#     _number of words_) within +fulltext+.  Note that these positions
#     rely on the precise way in which Solr splits words, which is specified
#     by {Unicode UAX #29.}[http://unicode.org/reports/tr29/]
#   - +:df+, document frequency: the number of documents in the collection
#     that contain this word
#   - +:tfidf+, term frequency-inverse document frequency: equal to (term
#     frequency / number of words in this document) * log(size of collection
#     / document frequency).  A measure of how "significant" or "important"
#     a given word is within a document, which gives high weight to words
#     that occur frequently in a given document but do _not_ occur in other
#     documents.
#
#   @note This attribute may be +nil+, if the query type requested from
#     the Solr server does not return term vectors.
#
#   @api public
#   @return [Hash] term vector information.  The hash contains the following
#     keys:
#       term_vectors['word']
#       term_vectors['word'][:tf] = Integer
#       term_vectors['word'][:offsets] = Array<Range>
#       term_vectors['word'][:offsets][0] = Range
#       # ...
#       term_vectors['word'][:positions] = Array<Integer>
#       term_vectors['word'][:positions][0] = Integer
#       # ...
#       term_vectors['word'][:df] = Float
#       term_vectors['word'][:tfidf] = Float
#       term_vectors['otherword']
#       # ...
#   @example Get the frequency of the term 'general' in this document
#     doc.term_vectors['general'][:tf]
class Document
  # Make this class act like an ActiveRecord model, though it's not backed by
  # the database (it's in Solr).
  include ActiveModel::Model

  attr_accessor :shasum, :doi, :license, :license_url, :authors,
                :author_list, :formatted_author_list, :title, :journal,
                :year, :volume, :number, :pages, :fulltext, :term_vectors

  # The shasum attribute is the only required one
  validates :shasum, presence: true
  validates :shasum, length: { is: 40 }
  validates :shasum, format: { with: /\A[a-fA-F\d]+\z/ }

  class << self
    # Registration for all serializers
    #
    # This variable is a hash of hashes.  For its format, see the documentation
    # for register_serializer.
    #
    # @api public
    # @return [Hash] the serializer registry
    # @example See if there is a serializer loaded for JSON
    #   Document.serializers.has_key? :json
    attr_accessor :serializers

    # Register a serializer
    #
    # @api public
    # @return [undefined]
    # @param [Symbol] key the MIME type key for this serializer, as defined
    #   in config/initializers/mime_types.rb
    # @param [String] name the human-readable name of this serializer format
    # @param [Proc] method a method which accepts a Document object as a
    #   parameter and returns the serialized document as a String
    # @param [String] docs a URL pointing to documentation for this method
    # @example Register a serializer for JSON
    #   Document.register_serializer (:json,
    #                                 'JSON',
    #                                 ->(doc) { doc.to_json },
    #                                 'http://www.json.org/')
    def register_serializer(key, name, method, docs)
      Document.serializers ||= { }
      Document.serializers[key] = { name: name, method: method, docs: docs }
    end
  end

  # Serialization methods
  include Serializers::BibTex
  include Serializers::CSL
  include Serializers::EndNote
  include Serializers::MARC
  include Serializers::MODS
  include Serializers::RDF
  include Serializers::RIS
  include Serializers::OpenURL

  # Return a document (just bibliographic data) by SHA-1 checksum
  #
  # @api public
  # @param [String] shasum SHA-1 checksum of the document to be retrieved
  # @param [Hash] options see +Solr::Connection.search+ for specification
  # @return [Document] the document requested
  # @raise [Solr::ConnectionError] thrown if there is an error querying Solr
  # @raise [ActiveRecord::RecordNotFound] thrown if no matching document can
  #   be found
  # @example Look up the document with ID '1234567890abcdef1234'
  #   doc = Document.find('1234567890abcdef1234')
  def self.find(shasum, options = {})
    result = Solr::Connection.search(options.merge({ q: "shasum:#{shasum}",
                                                     defType: 'lucene' }))
    fail ActiveRecord::RecordNotFound if result.num_hits != 1
    result.documents[0]
  end

  # Return a document (just bibliographic data) by SHA-1 checksum, or nil
  #
  # @api public
  # @param [String] shasum SHA-1 checksum of the document to be retrieved
  # @param [Hash] options see +Solr::Connection.search+ for specification
  # @return [Document] the document requested
  # @raise [Solr::ConnectionError] thrown if there is an error querying Solr
  # @raise [ActiveRecord::RecordNotFound] thrown if no matching document can
  #   be found
  # @example Look up the document with ID '1234567890abcdef1234'
  #   doc = Document.find_by_shasum('1234567890abcdef1234')
  # @example Look up a document that doesn't exist
  #   Document.find_by_shasum('1234567890abcdef1234')
  #   # => nil
  def self.find_by_shasum(shasum, options = {})
    result = Solr::Connection.search(options.merge({ q: "shasum:#{shasum}",
                                                     defType: 'lucene' }))
    return nil if result.num_hits != 1
    result.documents[0]
  end

  # Return a document (bibliographic data and full text) by SHA-1 checksum
  #
  # @api public
  # @param [String] shasum SHA-1 checksum of the document to be retrieved
  # @param [Hash] options see +Solr::Connection.search+ for specification
  # @return [Document] the document requested, including full text
  # @raise [Solr::ConnectionError] thrown if there is an error querying Solr
  # @raise [ActiveRecord::RecordNotFound] thrown if no matching document can
  #   be found
  # @example Get the full text of the document with ID '1234567890abcdef1234'
  #   text = Document.find_with_fulltext('1234567890abcdef1234').fulltext
  def self.find_with_fulltext(shasum, options = {})
    result = Solr::Connection.search(options.merge({ q: "shasum:#{shasum}",
                                                     defType: 'lucene',
                                                     tv: 'true',
                                                     fl: Solr::Connection::DEFAULT_FIELDS_FULLTEXT }))
    fail ActiveRecord::RecordNotFound if result.num_hits != 1
    result.documents[0]
  end

  # Return a document (bibliographic data and full text) by SHA-1 checksum,
  # or nil
  #
  # @api public
  # @param [String] shasum SHA-1 checksum of the document to be retrieved
  # @param [Hash] options see +Solr::Connection.search+ for specification
  # @return [Document] the document requested
  # @raise [Solr::ConnectionError] thrown if there is an error querying Solr
  # @raise [ActiveRecord::RecordNotFound] thrown if no matching document can
  #   be found
  # @example Get the full text of the document with ID '1234567890abcdef1234'
  #   doc = Document.find_by_shasum_with_fulltext('1234567890abcdef1234')
  # @example Look up a document that doesn't exist
  #   Document.find_by_shasum_with_fulltext('1234567890abcdef1234')
  #   # => nil
  def self.find_by_shasum_with_fulltext(shasum, options = {})
    result = Solr::Connection.search(options.merge({ q: "shasum:#{shasum}",
                                                     defType: 'lucene',
                                                     tv: 'true',
                                                     fl: Solr::Connection::DEFAULT_FIELDS_FULLTEXT }))
    return nil if result.num_hits != 1
    result.documents[0]
  end

  # @return [String] the starting page of this document, if it can be parsed
  def start_page
    return '' if pages.blank?
    pages.split('-')[0]
  end

  # @return [String] the ending page of this document, if it can be parsed
  def end_page
    return '' if pages.blank?
    parts = pages.split('-')
    return '' if parts.length <= 1

    spage = parts[0]
    epage = parts[-1]

    # Check for range strings like "1442-7"
    if spage.length > epage.length
      ret = spage
      ret[-epage.length..-1] = epage
    else
      ret = epage
    end
    ret
  end

  # Set all attributes and create author lists
  #
  # This constructor copies in all attributes, as well as splitting the
  # +authors+ value into +author_list+ and +formatted_author_list+.
  #
  # @api public
  # @param [Hash] attributes attributes for this document
  def initialize(attributes = {})
    super

    # Split out the author list and format it
    self.author_list = authors.split(',').map { |a| a.strip } unless authors.nil?
    unless author_list.nil?
      self.formatted_author_list = author_list.map do |a|
        BibTeX::Names.parse(a)[0]
      end
    end
  end
end
