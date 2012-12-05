# -*- encoding : utf-8 -*-
# spec/support/active_model_lint.rb
# adapted from rspec-rails

shared_examples_for "ActiveModel" do
  include ActiveModel::Lint::Tests

  ActiveModel::Lint::Tests.public_instance_methods.map{|m| m.to_s}.grep(/^test/).each do |m|
    example m.gsub('_',' ') do
      send m
    end
  end

  def model
    subject
  end
end
