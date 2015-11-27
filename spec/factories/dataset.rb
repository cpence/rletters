
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

    factory :full_dataset do
      transient do
        working false
        num_docs 5
      end

      after(:create) do |dataset, evaluator|
        if evaluator.num_docs > 0
          uids = (1..evaluator.num_docs).to_a.map { "\"#{FactoryGirl.generate(:working_uid)}\"" }
          query = "uid:(#{uids.join(' OR ')})"

          FactoryGirl.create(:query, dataset: dataset, q: query)
        end
      end
    end
  end

  factory :query, class: Datasets::Query do
    transient do
      working false
    end

    sequence(:q) do
      if working
        "uid:\"#{FactoryGirl.generate(:working_uid)}\""
      else
        'title:test'
      end
    end

    dataset
    fq nil
    def_type 'lucene'

    after(:create) do |query, _|
      query.update_size_cache
    end
  end
end
