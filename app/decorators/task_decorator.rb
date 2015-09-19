
# Decorate task objects
#
# This class adds methods to display the results from tasks.
class TaskDecorator < Draper::Decorator
  decorates Datasets::Task
  delegate_all

  # Create a link to download a given file, by content type
  #
  # @param [String] content_type the content type to download
  # @return [String] link to the file download (or `nil` if none)
  def download_path_for(content_type)
    file = file_for(content_type)
    return nil unless file

    h.download_dataset_task_path(dataset, object, file: files.index(file))
  end

  # Get the JSON content from a file if available
  #
  # If there is no JSON file attached to this task, this method will return
  # `nil`.
  #
  # @return [String] JSON data as string (or `nil`)
  def json
    files.each do |file|
      if file.result_content_type == 'application/json'
        return file.result.file_contents(:original).force_encoding('utf-8')
      end
    end

    nil
  end

  # Get the JSON content from a file, escaped for JavaScript
  #
  # If there is no JSON file attached to this task, this method will return
  # `nil`.
  #
  # @return [String] JSON data, escaped, as string (or `nil`)
  def json_escaped
    ret = json
    return nil if ret.nil?

    ret.gsub('\\', '\\\\')
       .gsub("'", "\\\\'")
       .gsub('\n', '\\\\\\\\n')
       .gsub('"', '\\\\"')
       .html_safe
  end

  # A user-friendly status/percentage message
  #
  # @return [String] percentage message
  def status_message
    ret = ''

    if progress
      ret += "#{(progress * 100).to_i}%"
      ret += ': ' if progress_message.present?
    end
    ret += progress_message if progress_message.present?

    ret
  end
end
