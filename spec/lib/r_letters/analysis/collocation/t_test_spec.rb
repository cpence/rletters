require 'spec_helper'
require_relative './shared_examples'

RSpec.describe RLetters::Analysis::Collocation::TTest do
  it_should_behave_like 'a collocation analyzer'
end
