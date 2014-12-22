# -*- encoding : utf-8 -*-

WORKING_UIDS ||= [
  'doi:10.1371/journal.pntd.0000534'.freeze,
  'doi:10.1371/journal.pntd.0000535'.freeze,
  'doi:10.1371/journal.pntd.0000536'.freeze,
  'doi:10.1371/journal.pntd.0000537'.freeze,
  'doi:10.1371/journal.pntd.0000538'.freeze,
  'doi:10.1371/journal.pntd.0000539'.freeze,
  'doi:10.1371/journal.pntd.0000540'.freeze,
  'doi:10.1371/journal.pntd.0000541'.freeze,
  'doi:10.1371/journal.pntd.0000542'.freeze,
  'doi:10.1371/journal.pntd.0000543'.freeze
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
        entries_count 5
      end

      after(:create) do |dataset, evaluator|
        dataset.entries = FactoryGirl.create_list(:entry,
                                                  evaluator.entries_count,
                                                  dataset: dataset,
                                                  working: evaluator.working)
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
