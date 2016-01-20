
module Admin
  # Decorate Administrator objects
  class QueJobDecorator < ApplicationRecordDecorator
    decorates Admin::QueJob
    delegate_all
  end
end
