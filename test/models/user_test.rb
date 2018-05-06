# frozen_string_literal: true
require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'should be invalid with no name' do
    user = build_stubbed(:user, name: nil)

    refute user.valid?
  end

  test 'should be invalid with no email' do
    user = build_stubbed(:user, email: nil)

    refute user.valid?
  end

  test 'should be invalid with duplicate email' do
    dupe = create(:user)
    user = build(:user, email: dupe.email)

    refute user.valid?
  end

  test 'should be invalid with bad email' do
    user = build(:user, email: 'asdf-not-an-email.com')

    refute user.valid?
  end

  test 'should be invalid with invalid language' do
    user = build_stubbed(:user, language: 'notalocaleCODE123')

    refute user.valid?
  end

  test 'should be valid with good attributes' do
    user = create(:user)

    assert user.valid?
  end

  test 'should not get workflow dataset for too-large' do
    user = create(:user, workflow_datasets: [])

    assert_raises(ActiveRecord::RecordNotFound) do
      user.workflow_dataset(0)
    end
  end

  test 'should not get workflow dataset for invalid' do
    user = create(:user, workflow_datasets: ['999999'])

    assert_raises(ActiveRecord::RecordNotFound) do
      user.workflow_dataset(0)
    end
  end

  test 'should get workflow dataset' do
    user = create(:user)
    dataset = create(:dataset, user: user)
    user.workflow_datasets = [dataset.to_param]
    user.save

    assert_equal dataset, user.workflow_dataset(0)
  end
end
