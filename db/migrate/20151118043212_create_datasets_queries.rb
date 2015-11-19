class CreateDatasetsQueries < ActiveRecord::Migration
  def up
    create_table :datasets_queries do |t|
      t.references :dataset
      t.string :q
      t.string :fq
      t.string :def_type

      t.timestamps null: false
    end

    puts '...migrating all dataset entries to queries'
    puts '   **IF POSSIBLE** it would be better to delete all datasets'
    puts '   and have users start from scratch!'

    # Turn all of the datasets_entries values into queries for 'uid:UID'
    select_all('SELECT * FROM datasets_entries').each do |h|
      query = "uid:\"#{h['uid']}\""
      execute "INSERT INTO datasets_queries (dataset_id, q, def_type, created_at, updated_at) values ('#{h['dataset_id']}', '#{query}', 'lucene', NOW(), NOW())"
    end

    drop_table :datasets_entries

    # Add the document count cache, and set it for the first time
    add_column :datasets, :document_count, :integer, default: 0
    update "UPDATE datasets SET document_count = (SELECT COUNT(*) FROM datasets_queries WHERE datasets_queries.dataset_id = datasets.id)"

    remove_column :datasets, :disabled
  end

  def down
    add_column :datasets, :disabled, :boolean
    execute "UPDATE datasets SET disabled=#{ActiveRecord::Base.connection.quoted_false}"

    remove_column :datasets, :document_count

    create_table :datasets_entries do |t|
      t.references :dataset
      t.string :uid

      t.timestamps null: true
    end

    # Turn all of the dataset queries back into entries lists
    select_all('SELECT * FROM datasets_queries').each do |h|
      res = RLetters::Solr::Connection.search(q: h['q'], fq: h['fq'], def_type: h['def_type'])
      res.documents.each do |doc|
        execute "INSERT INTO datasets_entries (dataset_id, uid, created_at, updated_at) values ('#{h['dataset_id']}', '#{doc.uid}', NOW(), NOW())"
      end
    end

    drop_table :datasets_queries
  end
end
