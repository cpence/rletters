# -*- encoding : utf-8 -*-
require 'spec_helper'
require_relative './shared_examples'

describe RLetters::Analysis::Collocation::LogLikelihood do
  it_should_behave_like 'a collocation analyzer'
end
