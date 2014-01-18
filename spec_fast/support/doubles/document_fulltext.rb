# -*- encoding : utf-8 -*-
require 'support/doubles/document_basic'
require 'support/doubles/term_vector_hash'

def double_document_fulltext(overrides = {})
  defaults = {
    term_vectors: term_vector_hash,
    fulltext: <<-eos
It was the best of times,
it was the worst of times,
it was the age of wisdom,
it was the age of foolishness,
it was the epoch of belief,
it was the epoch of incredulity,
it was the season of Light,
it was the season of Darkness,
it was the spring of hope,
it was the winter of despair,
we had everything before us,
we had nothing before us,
we were all going direct to Heaven,
we were all going direct the other way--
in short, the period was so far like the present period, that some of
its noisiest authorities insisted on its being received, for good or for
evil, in the superlative degree of comparison only.
eos
  }
  double_document_basic(defaults.merge(overrides))
end

def stub_document_fulltext(overrides = {})
  double = double_document_fulltext(overrides)

  fake = Class.new
  allow(fake).to receive(:find).and_return(double)
  stub_const('Document', fake)

  double
end
