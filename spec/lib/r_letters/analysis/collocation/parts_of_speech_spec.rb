# -*- encoding : utf-8 -*-
require 'spec_helper'
require_relative './shared_examples'

RSpec.describe RLetters::Analysis::Collocation::PartsOfSpeech do
  before(:each) do
    @old_path = Admin::Setting.nlp_tool_path
    Admin::Setting.nlp_tool_path = 'stubbed'

    @words = build(:parts_of_speech)
    expect_any_instance_of(described_class).to receive(:tagged_words_for).at_least(:once).and_return(@words)
  end

  after(:each) do
    Admin::Setting.nlp_tool_path = @old_path
  end

  it_should_behave_like 'a collocation analyzer'
end
