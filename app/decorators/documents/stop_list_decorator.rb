
module Documents
  # Decorate StopList objects
  class StopListDecorator < ApplicationRecordDecorator
    decorates Documents::StopList
    delegate_all
  end
end
