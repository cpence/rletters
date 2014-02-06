# -*- encoding : utf-8 -*-
require 'support/doubles/document_fulltext'
require 'support/doubles/dataset_fulltext'

def stub_stanford_ner_classifier
  doc_1_ft = 'Ethology 109, 905—910 (2003) © 2003 Blackwell Verlag, Berlin ISSN 0179-1613
Oviposition Behavior and Offspring Emergence Patterns in Succinea thaanumi, an Endemic Hawaiian Land Snail
Susan G. Brown, K'
  doc_2_ft = 'Outside the city of London.'

  doc_1 = stub_document_fulltext(fulltext: doc_1_ft)
  doc_2 = stub_document_fulltext(fulltext: doc_2_ft,
                                 uid: 'doi:10.2345/6789',
                                 doi: '10.2345/6789')

  dataset = stub_dataset_fulltext(nil, doc_1, doc_2)

  tuples_1 = [
    double(first: 'PERSON', second: '36', third: '52'),
    double(first: 'LOCATION', second: '54', third: '65'),
    double(first: 'LOCATION', second: '133', third: '141'),
    double(first: 'PERSON', second: '183', third: '197')
  ]
  tuples_2 = [
    double(first: 'LOCATION', second: '20', third: '26')
  ]

  stub_const('NLP_ENABLED', true)
  stub_const('NER_CLASSIFIER_PATH', '/asdf')

  stub_const('StanfordCoreNLP', Module.new)
  stub_const('StanfordCoreNLP::CRFClassifier', Class.new)

  classifier = double
  expect(classifier).to receive(:classifyToCharacterOffsets).with(doc_1_ft).and_return(tuples_1)
  expect(classifier).to receive(:classifyToCharacterOffsets).with(doc_2_ft).and_return(tuples_2)

  expect(StanfordCoreNLP::CRFClassifier).to receive(:getClassifierNoExceptions).and_return(classifier)

  dataset
end
