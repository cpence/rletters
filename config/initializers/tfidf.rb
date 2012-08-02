
module Math

  # Extend the Math module with a few useful functions.

  # Compute the term frequency-inverse document frequency for a term
  #
  # @param [Integer] tf The frequency of this term in the document
  # @param [Integer] df The number of documents containing this term
  # @param [Integer] num_docs The number of documents in the corpus
  # @return [Float] The term frequency-inverse document frequency
  def self.tfidf(tf, df, num_docs)
    tf * Math.log10(num_docs.to_f / df.to_f)
  end
end
