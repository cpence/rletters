
# Export all of the data belonging to a user
class UserExportJob < ActiveJob::Base
  # Export all of a user's data as a ZIP file
  #
  # @param [User] user the user whose data we want to export
  # @return [void]
  def perform(user)
    fail 'Attempted to export a non-user object' unless user.is_a?(User)

    # All of this goes into a ZIP file
    ios = ::Zip::OutputStream.write_buffer(StringIO.new('')) do |zos|
      # Every user column, straight off the schema
      user_data = {
        name: user.name,
        email: user.email,
        created_at: user.created_at.to_s,
        updated_at: user.updated_at.to_s,
        language: user.language,
        timezone: user.timezone,
        encrypted_password: user.encrypted_password,
        reset_password_token: user.reset_password_token,
        reset_password_sent_at: user.reset_password_sent_at.to_s,
        remember_created_at: user.remember_created_at.to_s,
        sign_in_count: user.sign_in_count.to_s,
        current_sign_in_at: user.current_sign_in_at.to_s,
        last_sign_in_at: user.last_sign_in_at.to_s,
        current_sign_in_ip: user.current_sign_in_ip,
        last_sign_in_ip: user.last_sign_in_ip,
        workflow_active: user.workflow_active,
        workflow_class: user.workflow_class,
        workflow_datasets: user.workflow_datasets.to_s
      }

      # This is a reference to another class, go get the name
      if user.csl_style
        user_data[:csl_style] = user.csl_style.name
      end

      # Serialize it to the ZIP
      zos.put_next_entry('user.json')
      zos.print user_data.to_json

      # Libraries
      libraries = []
      user.libraries.each do |l|
        library = {
          name: l.name,
          url: l.url,
          created_at: l.created_at.to_s,
          updated_at: l.updated_at.to_s
        }

        libraries << library
      end

      zos.put_next_entry('libraries.json')
      zos.print libraries.to_json

      # Datasets
      datasets = []
      files_to_save = {}

      user.datasets.each do |d|
        dataset = {
          name: d.name,
          created_at: d.created_at.to_s,
          updated_at: d.updated_at.to_s,
          fetch: d.fetch,
          document_count: d.document_count.to_s,
          queries: [],
          tasks: []
        }

        d.queries.each do |q|
          query = {
            q: q.q,
            fq: q.fq,
            def_type: q.def_type,
            created_at: q.created_at.to_s,
            updated_at: q.updated_at.to_s
          }

          dataset[:queries] << query
        end

        d.tasks.each do |t|
          task = {
            name: t.name,
            finished_at: t.finished_at.to_s,
            created_at: t.created_at.to_s,
            updated_at: t.updated_at.to_s,
            failed: t.failed,
            job_type: t.job_type,
            progress: t.progress,
            progress_message: t.progress_message,
            last_progress: t.last_progress.to_s,
            job_id: t.job_id,
            files: []
          }

          t.files.each do |f|
            unless f.result
              task[:files] << '<empty file record>'
              next
            end

            filename = "#{t.to_param}_#{f.to_param}_#{f.result_file_name}"
            files_to_save[filename] = f.result
            task[:files] << filename
          end

          dataset[:tasks] << task
        end

        datasets << dataset
      end

      zos.put_next_entry('datasets.json')
      zos.print datasets.to_json

      # And all of the files
      files_to_save.each do |filename, file|
        zos.put_next_entry(filename)
        zos.write(Paperclip.io_adapters.for(file).read)
      end
    end

    # Save it into the user object, and they'll be able to download it
    ios.rewind

    file = Paperclip.io_adapters.for(ios)
    file.original_filename = 'export.zip'
    file.content_type = 'application/zip'

    user.export_archive = file
    user.save
  end
end
