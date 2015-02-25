# spec/support/active_model_lint.rb
# adapted from rspec-rails

RSpec.shared_examples_for 'ActiveModel' do
  include ActiveModel::Lint::Tests

  methods = ActiveModel::Lint::Tests.public_instance_methods
  methods.map(&:to_s).grep(/^test/).each do |m|
    example m.tr('_', ' ') do
      send m
    end
  end

  def model
    subject
  end
end
