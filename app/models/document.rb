# -*- encoding : utf-8 -*-

# Representation of a document in the Solr database
#
# This class provides an ActiveRecord-like model object for documents hosted in
# the RLetters Solr backend.  It abstracts both single-document retrieval and
# document searching in class-level methods, and access to the data provided by
# Solr in instance-level methods and attributes.
#
# @!attribute [r] uid
#   @raise [RecordInvalid] if the uid is missing (validates :presence)
#   @return [String] the uid of this document
# @!attribute [r] doi
#   @return [String] the DOI (Digital Object Identifier) of this document
#
# @!attribute [r] license
#   @return [String] the human-readable name of the document's license
# @!attribute [r] license_url
#   @return [String] a URL referencing the document's license terms
# @!attribute [r] data_source
#   @return [String] a description of where this document's data was obtained
#
# @!attribute [r] authors
#   @return [RLetters::Documents::Authors] the document's authors, parsed into
#     +Author+ objects
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
#
# @!attribute [r] fulltext
#   If +fulltext_url+ is set, this variable will be transparently set to the
#   fetched text when a document is retrieved from the server with fulltext
#   requested.
#
#   @return [String] the full text of this document.  May be +nil+ if the query
#     type used to retrieve the document does not provide the full text
# @!attribute [r] fulltext_url
#   @return [URI] if present, the URL from which to fetch the full text.  May
#     be +nil+ if the text is stored locally
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

  attr_accessor :uid, :doi, :license, :license_url, :data_source, :authors,
                :title, :journal, :year, :volume, :number, :pages, :fulltext,
                :fulltext_url, :term_vectors

  # The uid attribute is the only required one
  validates :uid, presence: true

  # Return a document (just bibliographic data) by uid
  #
  # @api public
  # @param [String] uid uid of the document to be retrieved
  # @param [Hash] options options which modify the behavior of the search
  # @option options [Boolean] fulltext if true, return document full text
  # @option options [Boolean] term_vectors if true, return term vectors
  # @return [Document] the document requested
  # @raise [RLetters::Solr::ConnectionError] thrown if there is an error
  #   querying Solr
  # @raise [ActiveRecord::RecordNotFound] thrown if no matching document can
  #   be found
  # @example Look up the document with UID '1234567890abcdef1234'
  #   doc = Document.find('1234567890abcdef1234')
  def self.find(uid, options = {})
    find_by!(uid: uid, fulltext: options[:fulltext],
             term_vectors: options[:term_vectors])
  end

  # Query a document and raise an exception if it's not found
  #
  # @api public
  # @api public
  # @option args [Boolean] fulltext if true, return the full text of the
  #   document if found
  # @option args [Boolean] term_vectors if true, return term vectors
  # @option args [String] field any document field may be queried here as a
  #   search query (see example)
  # @return [Document] the document requested, or nil if not found
  # @raise [RLetters::Solr::ConnectionError] thrown if there is an error
  #   querying Solr
  # @raise [ActiveRecord::RecordNotFound] thrown if no matching document can
  #   be found
  # @example Look up a document by W. Shatner (raising exception if not found)
  #   doc = Document.find_by!(authors: 'W. Shatner')
  def self.find_by!(args)
    find_by(args) or fail ActiveRecord::RecordNotFound
  end

  # Query a document and return it (or nil)
  #
  # @api public
  # @option args [Boolean] fulltext if true, return the full text of the
  #   document if found
  # @option args [Boolean] term_vectors if true, return term vectors
  # @option args [String] field any document field may be queried here as a
  #   search query (see example)
  # @return [Document] the document requested, or nil if not found
  # @raise [RLetters::Solr::ConnectionError] thrown if there is an error
  #   querying Solr
  # @example Look up a document by W. Shatner (returning nil if not found)
  #   doc = Document.find_by(authors: 'W. Shatner')
  def self.find_by(args)
    # Delete the special arguments
    fulltext = args.delete(:fulltext)
    term_vectors = args.delete(:term_vectors)

    # Build the query
    query = { def_type: 'lucene' }
    query[:q] = args.map { |k, v| "#{k}:\"#{v}\"" }.join(' AND ')
    if fulltext == true
      query[:fl] = RLetters::Solr::Connection::DEFAULT_FIELDS_FULLTEXT
    end
    if term_vectors == true
      query[:tv] = 'true'
    end

    # Run the search
    result = RLetters::Solr::Connection.search(query)
    return nil if result.num_hits < 1
    doc = result.documents[0]

    # If the full text is requested, fetch it if we have to
    if fulltext == true && doc.fulltext_url
      text = Net::HTTP.get(doc.fulltext_url)
      text.encode!('utf-8', invalid: :replace, undef: :replace, replace: '')

      # Some websites return a UTF-8 BOM, strip it if it's found
      text.sub!("\xEF\xBB\xBF", '') if text.start_with?("\xEF\xBB\xBF")

      doc.fulltext = text
    end

    doc
  end

  # @return [String] the document UID, sanitized for use as an HTML attribute
  def html_uid
    uid ? uid.gsub(/[^0-9a-zA-Z\-_]/, '_') : nil
  end

  # @return [String] the starting page of this document, if it can be parsed
  def start_page
    return nil unless pages
    pages.split('-')[0]
  end

  # @return [String] the ending page of this document, if it can be parsed
  def end_page
    return nil unless pages
    parts = pages.split('-')
    return nil if parts.length <= 1

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
  # +authors+ value.
  #
  # @api public
  # @param [Hash] attributes attributes for this document
  def initialize(attributes = {})
    super

    # Don't let any blank strings hang around as values for the Solr
    # fields. This prevents a whole lot of #blank? and #present? calls
    # throughout. Also note that we're explicitly not setting the
    # authors here, that's done specially.
    [:uid, :doi, :license, :license_url,
     :data_source, :title, :journal,
     :year, :volume, :number, :pages,
     :fulltext].each do |a|
      value = send(a)
      if value && value.strip.empty?
        send("#{a}=".to_sym, nil)
      end
    end

    # Convert the fulltext_url into a URI
    if fulltext_url
      self.fulltext_url = URI.parse(fulltext_url)
    end

    # Convert the authors into an authors object (and do this even if the
    # string is nil or blank)
    self.authors = RLetters::Documents::Authors.from_list(authors)
  end
end
