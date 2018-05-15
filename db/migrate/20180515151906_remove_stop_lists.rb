# frozen_string_literal: true

class RemoveStopLists < ActiveRecord::Migration[5.2]
  def change
    drop_table 'documents_stop_lists' do |t|
      t.string :language, limit: 255
      t.text :list
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
