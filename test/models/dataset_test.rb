require 'test_helper'

class DatasetTest < ActiveSupport::TestCase
  test 'should not be valid with no name' do
    dataset = build_stubbed(:dataset, name: nil)

    refute dataset.valid?
  end

  test 'should not be valid with no user' do
    dataset = build_stubbed(:dataset, user: nil)

    refute dataset.valid?
  end

  test 'should be valid with user and name' do
    dataset = create(:dataset)

    assert dataset.valid?
  end

  test 'should associate with tasks' do
    dataset = create(:dataset)
    task = create(:task, dataset: dataset, name: 'test')

    assert_equal 1, dataset.tasks.reload.size
    assert_equal 'test', dataset.tasks[0].name
  end

  test 'should associate with users' do
    user = create(:user)
    dataset = create(:full_dataset, user: user, num_docs: 2)

    assert_equal 1, user.datasets.reload.size
  end

  test 'should build queries' do
    dataset = create(:full_dataset, num_docs: 2)

    assert_equal 1, dataset.queries.size
  end

  test 'should save number of documents' do
    dataset = create(:full_dataset, num_docs: 2)

    assert_equal 2, dataset.document_count
  end
end
