# frozen_string_literal: true
require 'test_helper'
require_relative './common_tests'

class RLetters::Documents::Serializers::BibTexTest < ActiveSupport::TestCase
  include RLetters::Documents::Serializers::CommonTests

  test 'single document serialization' do
    doc = build(:full_document)
    str = RLetters::Documents::Serializers::BibTex.new(doc).serialize

    assert str.start_with?('@article{Dickens1859,')
    assert_includes str, 'author = {C. Dickens}'
    assert_includes str, 'title = {A Tale of Two Cities}'
    assert_includes str, 'journal = {Actually a Novel}'
    assert_includes str, 'volume = {1}'
    assert_includes str, 'number = {1}'
    assert_includes str, 'pages = {1}'
    assert_includes str, 'doi = {10.5678/dickens}'
    assert_includes str, 'year = {1859}'
  end

  test 'array serialization' do
    doc = build(:full_document)
    docs = [doc, doc]
    str = RLetters::Documents::Serializers::BibTex.new(docs).serialize

    # FIXME: This is actually a sort of failure case -- we aren't deduplicating
    # the citation keys in any way!
    assert str.start_with?('@article{Dickens1859,')
    assert_includes str, "}\n@article{Dickens1859,"
  end

  test 'anonymous documents' do
    doc = build(:full_document, authors: nil)
    str = RLetters::Documents::Serializers::BibTex.new(doc).serialize

    assert str.start_with?('@article{Anon1859,')
  end
end
