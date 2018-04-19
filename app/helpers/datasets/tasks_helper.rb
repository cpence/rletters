
module Datasets
  module TasksHelper
    # Create a link to download a given file, by content type
    #
    # @param [Datasets::Task] task the task to download from
    # @param [String] content_type the content type to download
    # @return [String] link to the file download (or `nil` if none)
    def task_download_path(task:, content_type:)
      file = task.file_for(content_type)
      return nil unless file

      url_for(file.result)
    end
  end
end
