# -*- encoding : utf-8 -*-

WORKING_UIDS = [
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

CSL_DATA = File.read(Rails.root.join('spec', 'factories', 'nature.csl'))

FactoryGirl.define do

  sequence :working_uid do |n|
    WORKING_UIDS[n % WORKING_UIDS.size]
  end

  factory :administrator, class: Admin::Administrator do
    sequence(:email) { |n| "admin#{n}@example.com" }
    password 'password'
    password_confirmation 'password'
    remember_me false
  end

  factory :analysis_task, class: Datasets::AnalysisTask do
    name 'Analysis Task'
    dataset
    job_type 'FakeJob'
  end

  factory :category, class: Documents::Category do
    name 'Test Category'
    journals ['Ethology']
  end

  factory :csl_style, class: Users::CslStyle do
    name 'Nature'
    style CSL_DATA
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
        dataset.entries = evaluator.entries_count.times.map do
          FactoryGirl.create(:entry, dataset: dataset,
                                     working: evaluator.working)
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

  factory :download do
    filename 'test.txt'
    analysis_task
  end

  factory :library, class: Users::Library do
    name 'Harvard'
    sequence(:url) { |n| "http://sfx.hul.harvard#{n}.edu/sfx_local?" }
    user
  end

  factory :markdown_page, class: Admin::MarkdownPage do
    name 'test_page'
    content '# Header'
  end

  factory :uploaded_asset, class: Admin::UploadedAsset do
    name 'test_asset'
    file { File.new(Rails.root.join('spec', 'factories', '1x1.png')) }
  end

  factory :stop_list, class: Documents::StopList do
    language 'en'
    list 'a an the'
  end

  factory :user do
    name 'John Doe'
    sequence(:email) { |n| "person#{n}@example.com" }
    password 'password'
    password_confirmation 'password'
    remember_me false
    per_page 10
    language 'en'
    timezone 'Eastern Time (US & Canada)'
  end

end
