require 'spec_helper'
require_relative './shared_examples'

RSpec.describe RLetters::Analysis::Cooccurrence::MutualInformation do
  it_should_behave_like 'a cooccurrence analyzer'
end
