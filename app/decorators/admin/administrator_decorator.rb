
module Admin
  # Decorate Administrator objects
  class AdministratorDecorator < ApplicationRecordDecorator
    decorates Admin::Administrator
    delegate_all
  end
end
