
module Users
  # Decorate CslStyle objects
  class CslStyleDecorator < ApplicationRecordDecorator
    decorates Users::CslStyle
    delegate_all
  end
end
