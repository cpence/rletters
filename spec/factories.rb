
CSL_DATA ||= File.read(Rails.root.join('spec', 'factories', 'nature.csl'))
POS_YAML ||= File.read(Rails.root.join('spec', 'factories', 'parts_of_speech.yml'))

FactoryGirl.define do
  factory :administrator, class: Admin::Administrator do
    sequence(:email) { |n| "admin#{n}@example.com" }
    password 'password'
    password_confirmation 'password'
    remember_me false
  end

  factory :benchmark, class: Admin::Benchmark do
    job 'ArticleDatesJob'
    size 10
    time 60.0
  end

  factory :file, class: Datasets::File do
    description 'A task file'
    short_description 'File'
    task
  end

  factory :task, class: Datasets::Task do
    name 'Task'
    dataset
    job_type 'FakeJob'
  end

  factory :category, class: Documents::Category do
    name 'Test Category'
    journals ['PLoS Neglected Tropical Diseases']
  end

  factory :csl_style, class: Users::CslStyle do
    name 'Nature'
    style CSL_DATA
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

  factory :named_entities, class: Hash do
    transient do
      entity_hash {
        { 'PERSON' => %w(Tom Dick Harry) }
      }
    end

    initialize_with do
      entity_hash
    end
  end

  factory :parts_of_speech, class: Array do
    transient do
      yml POS_YAML
    end

    initialize_with do
      YAML.load(yml)
    end
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
    language 'en'
    timezone 'Eastern Time (US & Canada)'
  end
end
