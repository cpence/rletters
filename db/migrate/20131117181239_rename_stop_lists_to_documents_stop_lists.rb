# -*- encoding : utf-8 -*-
class RenameStopListsToDocumentsStopLists < ActiveRecord::Migration
  def change
    rename_table 'stop_lists', 'documents_stop_lists'
  end
end
