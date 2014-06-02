# -*- encoding : utf-8 -*-
require 'spec_helper'
require_relative './shared_examples'

RSpec.describe RLetters::Analysis::Collocation::PartsOfSpeech, nlp: true do
  it_should_behave_like 'a collocation analyzer'
end
