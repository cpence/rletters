# frozen_string_literal: true

WORKING_UIDS ||= [
  'doi:10.1371/journal.pntd.0000534',
  'doi:10.1371/journal.pntd.0000535',
  'doi:10.1371/journal.pntd.0000536',
  'doi:10.1371/journal.pntd.0000537',
  'doi:10.1371/journal.pntd.0000538',
  'doi:10.1371/journal.pntd.0000539',
  'doi:10.1371/journal.pntd.0000540',
  'doi:10.1371/journal.pntd.0000541',
  'doi:10.1371/journal.pntd.0000542',
  'doi:10.1371/journal.pntd.0000543'
].freeze

FactoryBot.define do
  sequence :working_uid do |n|
    WORKING_UIDS[n % WORKING_UIDS.size]
  end

  factory :dataset do
    name { 'Dataset' }
    user

    factory :full_dataset do
      transient do
        num_docs { 5 }
      end

      after(:create) do |dataset, evaluator|
        if evaluator.num_docs.positive?
          uids = (1..evaluator.num_docs).to_a.map { "\"#{FactoryBot.generate(:working_uid)}\"" }
          query = "uid:(#{uids.join(' OR ')})"

          FactoryBot.create(:query, dataset: dataset, q: query)
        end
      end
    end
  end

  factory :query, class: Datasets::Query do
    sequence(:q) do
      "uid:\"#{FactoryBot.generate(:working_uid)}\""
    end

    dataset
    fq { nil }
    def_type { 'lucene' }

    after(:create) do |query, _|
      query.update_size_cache
    end
  end
end
