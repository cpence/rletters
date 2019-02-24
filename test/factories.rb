# frozen_string_literal: true

FactoryBot.define do
  factory :file, class: Datasets::File do
    description { 'A task file' }
    short_description { 'File' }
    task
  end

  factory :task, class: Datasets::Task do
    name { 'Task' }
    dataset
    job_type { 'FakeJob' }
  end

  factory :category, class: Documents::Category do
    name { 'Test Category' }
    journals { ['PLoS Neglected Tropical Diseases'] }
  end

  factory :library, class: Users::Library do
    name { 'Harvard' }
    sequence(:url) { |n| "http://sfx.hul.harvard#{n}.edu/sfx_local?" }
    user
  end

  factory :snippet, class: Admin::Snippet do
    name { 'test' }
    language { :en }
    content { '# Header' }
  end

  factory :named_entities, class: Hash do
    transient do
      entity_hash do
        { 'PERSON' => %w[Tom Dick Harry] }
      end
    end

    initialize_with do
      entity_hash
    end
  end

  factory :asset, class: Admin::Asset do
    name { 'test_asset' }
    file { Rack::Test::UploadedFile.new(Rails.root.join('test', 'factories', '1x1.png')) }
  end

  factory :worker_stat, class: Admin::WorkerStats do
    worker_type { 'test worker' }
    host { 'localhost' }
    pid { 1 }
    started_at { '2018-04-20 10:28:33' }
  end

  factory :user do
    name { 'John Doe' }
    sequence(:email) { |n| "person#{n}@example.com" }
    password { 'password' }
    password_confirmation { 'password' }
    remember_me { false }
    language { 'en' }
    timezone { 'Eastern Time (US & Canada)' }
  end
end
