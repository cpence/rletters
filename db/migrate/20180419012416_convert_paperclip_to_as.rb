Dir[Rails.root.join("app/models/**/*.rb")].sort.each { |file| require file }

class ConvertPaperclipToAs < ActiveRecord::Migration[5.2]
  def up
    get_blob_id = 'LASTVAL()'

    active_storage_blob_statement = ActiveRecord::Base.connection.raw_connection.prepare('blob_stmt', <<-SQL)
      INSERT INTO active_storage_blobs (
        key, filename, content_type, metadata, byte_size,
        checksum, created_at
      ) VALUES ($1, $2, $3, '{}', $4, $5, $6)
    SQL

    active_storage_attachment_statement = ActiveRecord::Base.connection.raw_connection.prepare('attach_stmt', <<-SQL)
      INSERT INTO active_storage_attachments (
        name, record_type, record_id, blob_id, created_at
      ) VALUES ($1, $2, $3, #{get_blob_id}, $4)
    SQL

    models = ActiveRecord::Base.descendants.reject(&:abstract_class?)

    transaction do
      models.each do |model|
        attachments = model.column_names.map do |c|
          if c =~ /(.+)_file_name$/
            $1
          end
        end.compact

        model.find_each.each do |instance|
          attachments.each do |attachment|
            k = key(instance, attachment)

            # Copy the file over
            source = instance.send(attachment).path
            dest_dir = File.join(
              'storage',
              k.first(2),
              k.first(4).last(2))
            dest = File.join(dest_dir, k)

            FileUtils.mkdir_p(dest_dir)
            puts "Moving #{source} to #{dest}"
            FileUtils.cp(source, dest)

            ActiveRecord::Base.connection.raw_connection.exec_prepared('blob_stmt', [
              k,
              dest,
              instance.send("#{attachment}_content_type"),
              instance.send("#{attachment}_file_size"),
              checksum(dest),
              instance.updated_at.iso8601
            ])

            ActiveRecord::Base.connection.raw_connection.exec_prepared('attach_stmt', [
              attachment, model.name, instance.id, instance.updated_at.iso8601])
          end
        end
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def key(instance, attachment)
    SecureRandom.uuid
  end

  def checksum(url)
    Digest::MD5.base64digest(File.read(url))
  end
end
