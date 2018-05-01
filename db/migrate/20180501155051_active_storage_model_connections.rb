class ActiveStorageModelConnections < ActiveRecord::Migration[5.2]
  def up
    ActiveRecord::Base.connection.execute "UPDATE active_storage_attachments SET record_type = #{ActiveRecord::Base.connection.quote('Admin::Asset')} WHERE record_type = #{ActiveRecord::Base.connection.quote('Admin::UploadedAsset')}"
  end

  def down
    ActiveRecord::Base.connection.execute "UPDATE active_storage_attachments SET record_type = #{ActiveRecord::Base.connection.quote('Admin::UploadedAsset')} WHERE record_type = #{ActiveRecord::Base.connection.quote('Admin::Asset')}"
  end
end
