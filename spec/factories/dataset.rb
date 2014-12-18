# -*- encoding : utf-8 -*-

WORKING_UIDS ||= [
  'doi:10.1111/j.1439-0310.2009.01707.x'.freeze,
  'doi:10.1046/j.0179-1613.2003.00929.x'.freeze,
  'doi:10.1046/j.1439-0310.2000.00539.x'.freeze,
  'doi:10.1111/j.1439-0310.2009.01716.x'.freeze,
  'doi:10.1111/j.1439-0310.2008.01576.x'.freeze,
  'doi:10.1046/j.1439-0310.2001.00723.x'.freeze,
  'doi:10.1111/j.1439-0310.2011.01898.x'.freeze,
  'doi:10.1111/j.1439-0310.1998.tb00103.x'.freeze,
  'doi:10.1111/j.1439-0310.2006.01139.x'.freeze,
  'doi:10.1111/j.1439-0310.2007.01421.x'.freeze
].freeze

FactoryGirl.define do

  sequence :working_uid do |n|
    WORKING_UIDS[n % WORKING_UIDS.size]
  end

  factory :dataset do
    transient do
      working false
    end

    name 'Dataset'
    user
    disabled false

    factory :full_dataset do
      transient do
        working false
        stub false
        english false
        entries_count 5
      end

      after(:build) do |dataset, evaluator|
        if evaluator.stub
          doc = if evaluator.english
                  FactoryGirl.build(:full_document_english)
                else
                  FactoryGirl.build(:full_document)
                end

          allow(Document).to receive(:find).and_return(doc)
          allow(Document).to receive(:find_by).and_return(doc)
          allow(Document).to receive(:find_by!).and_return(doc)

          # Just include the one document N times
          dataset.entries = evaluator.entries_count.times.map do
            FactoryGirl.create(:entry, dataset: dataset, uid: doc.uid)
          end

          # Stub out the enumerator, too
          allow_any_instance_of(RLetters::Datasets::DocumentEnumerator).to receive(:each) do |&arg|
            evaluator.entries_count.times { arg.call(doc) }
          end
        end
      end

      after(:create) do |dataset, evaluator|
        unless evaluator.stub
          dataset.entries = evaluator.entries_count.times.map do
            FactoryGirl.create(:entry, dataset: dataset,
                                       working: evaluator.working)
          end
        end
      end
    end
  end

  factory :entry, class: Datasets::Entry do
    transient do
      working false
    end

    sequence(:uid) do |n|
      if working
        FactoryGirl.generate(:working_uid)
      else
        "doi:10.1234/this.is.a.doi.#{n}"
      end
    end

    dataset
  end
end
