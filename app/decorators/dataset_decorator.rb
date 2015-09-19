
# Decorate dataset objects
#
# This class ensures that tasks are always decorated
class DatasetDecorator < Draper::Decorator
  decorates Dataset
  delegate_all

  decorates_association :tasks, with: TaskDecorator

  # It's a pain that we have to pass all of these scoped objects through here,
  # but there's no automated way to deal with scopes in Draper. There's a
  # pull request for this open, but no action lately.
  def finished_tasks
    TaskDecorator.decorate_collection(object.tasks.finished)
  end

  def not_finished_tasks
    TaskDecorator.decorate_collection(object.tasks.not_finished)
  end

  def active_tasks
    TaskDecorator.decorate_collection(object.tasks.active)
  end

  def failed_tasks
    TaskDecorator.decorate_collection(object.tasks.failed)
  end
end
