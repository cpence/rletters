# -*- encoding : utf-8 -*-
require 'spec_helper'
require_relative './shared_examples'

RSpec.describe RLetters::Analysis::Cooccurrence::LogLikelihood do
  it_should_behave_like 'a cooccurrence analyzer'
end
