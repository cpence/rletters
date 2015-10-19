require 'rails_helper'
require_relative './shared_examples'

RSpec.describe RLetters::Analysis::Collocation do
  [:mutual_information, :t_test, :log_likelihood].each do |scoring|
    it_should_behave_like 'a collocation analyzer', scoring
  end
end
