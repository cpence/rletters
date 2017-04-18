require 'rails_helper'
require_relative './shared_examples'

RSpec.describe RLetters::Analysis::Collocation do
  [:mutual_information, :t_test, :log_likelihood].each do |scoring|
    it_should_behave_like 'a collocation analyzer', scoring
  end

  it 'throws an exception when the scoring type is invalid' do
    dataset = create(:full_dataset)
    expect {
      described_class.call(scoring: :nope, dataset: dataset)
    }.to raise_error(ArgumentError)
  end
end
