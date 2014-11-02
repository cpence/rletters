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

  factory :document do
    transient do
      uid 'doi:10.1234/this.is.a.doi'
      doi nil
      license nil
      license_url nil
      authors nil
      title nil
      journal nil
      year nil
      volume nil
      number nil
      pages nil
      fulltext nil
    end

    factory :full_document do
      transient do
        uid 'doi:10.1111/j.1439-0310.2008.01576.x'
        doi '10.1111/j.1439-0310.2008.01576.x'
        license '© Blackwell Verlag GmbH'
        license_url 'http://onlinelibrary.wiley.com/journal/10.1111/(ISSN)1439-0310/homepage/Permissions.html'
        authors 'Carlos A. Botero, Andrew E. Mudge, Amanda M. Koltz, Wesley M. Hochachka, Sandra L. Vehrencamp'
        title 'How Reliable are the Methods for Estimating Repertoire Size?'
        journal 'Ethology'
        year '2008'
        volume '114'
        pages '1227-1238'
        fulltext 'Ethology How Reliable are the Methods for Estimating Repertoire Size?'
      end
    end

    initialize_with do
      Document.new(uid: uid, doi: doi, license: license,
                   license_url: license_url, authors: authors, title: title,
                   journal: journal, year: year, volume: volume,
                   number: number, pages: pages, fulltext: fulltext)
    end
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
    file { File.new(Rails.root.join('db', 'seeds', 'images', 'favicon.ico')) }
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
