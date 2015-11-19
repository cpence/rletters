require 'rails_helper'

RSpec.describe ExpireTasksJob, type: :job do
  before(:example) do
    @user = create(:user)
    @dataset = create(:full_dataset, user: @user, num_docs: 0)
    create(:query, dataset: @dataset, q: "uid:\"#{WORKING_UIDS[2]}\"")
    @old_task = create(:task, dataset: @dataset, created_at: 3.weeks.ago)
    @new_task = create(:task, dataset: @dataset, created_at: 3.days.ago)
  end

  it 'works' do
    described_class.new.perform
    expect(Datasets::Task.exists?(@old_task.id)).to be false
    expect(Datasets::Task.exists?(@new_task.id)).to be true
  end
end
