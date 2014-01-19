# -*- encoding : utf-8 -*-
require 'support/doubles/document_fulltext'

def double_dataset_fulltext(user = nil)
  doc_1 = stub_document_fulltext
  doc_2 = stub_document_fulltext(uid: 'doi:10.2345/6789', doi: '10.2345/6789')

  dataset = double('Dataset', name: 'Test Dataset', user: user,
                              disabled: false, fetch: false)

  entry_1 = double('Datasets::Entry', uid: doc_1.uid)
  entry_2 = double('Datasets::Entry', uid: doc_2.uid)

  entries = [entry_1, entry_2]
  allow(entries).to receive(:find_in_batches) do |&arg|
    arg.call([entry_1, entry_2])
  end

  allow(dataset).to receive(:entries).and_return(entries)

  dataset
end
