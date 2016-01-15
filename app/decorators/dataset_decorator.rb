
# Decorate dataset objects
#
# This class ensures that tasks are always decorated
class DatasetDecorator < ApplicationRecordDecorator
  decorates Dataset
  delegate_all

  decorates_association :user, with: UserDecorator
  decorates_association :queries, with: Datasets::QueryDecorator
  decorates_association :tasks, with: Datasets::TaskDecorator

  # It's a pain that we have to pass all of these scoped objects through here,
  # but there's no automated way to deal with scopes in Draper. There's a
  # pull request for this open, but no action lately.
  def finished_tasks
    Datasets::TaskDecorator.decorate_collection(object.tasks.finished)
  end

  def not_finished_tasks
    Datasets::TaskDecorator.decorate_collection(object.tasks.not_finished)
  end

  def active_tasks
    Datasets::TaskDecorator.decorate_collection(object.tasks.active)
  end

  def failed_tasks
    Datasets::TaskDecorator.decorate_collection(object.tasks.failed)
  end
end
