
module Datasets
  # Decorate File objects
  class FileDecorator < ApplicationRecordDecorator
    decorates Datasets::File
    delegate_all
  end
end
