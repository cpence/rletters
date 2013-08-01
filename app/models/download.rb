# -*- encoding : utf-8 -*-

# A generated file, stored for the user to download
#
# A download object is generated when a delayed job needs to send some data
# back to the user.  We keep track of them in the database so that they can
# be expired and deleted when necessary.
#
# All files are stored in +RAILS_ROOT/downloads+, *not* in the +public+ tree,
# so that it is impossible to get the web server to serve the download files
# without passing through the RLetters's authentication. This folder is
# expected to be symlinked over from +shared+ during a Capistrano deployment.
class Download < ActiveRecord::Base
  validates :filename, :presence => true
  # :filename_before_type_cast gives you the value of the filename attribute
  # without passing it through our custom accessor, which turns the relative
  # database path into an absolute filesystem path.
  validates :filename_before_type_cast, :format => { :with => /\A[A-Za-z0-9.\-_]+\z/ }

  belongs_to :analysis_task

  before_destroy :delete_file

  # Creates a download object and file, then passes the file to the block
  #
  # This function will create the file +basename+ in the downloads folder
  # (do not put a path of any sort on +basename+).  A unique timestamp will
  # be appended to the filename, and the file created.  The file handle will
  # then be passed to the provided block.  Finally, the function creates a
  # +Download+ model, saves it in the database, and returns it.
  #
  # Closing the file within the block is optional; it will be closed when
  # the block terminates if it hasn't been already.
  #
  # @api public
  # @param basename [String] the base name of the file to create
  # @yield [f] a File object, opened for writing
  # @yieldparam [File] f the file object created
  # @return [Download] a new +Download+ object
  #
  # @example Create a file
  #   dl = Download.create_file('test.txt') do |f|
  #     f.write("1234567890")
  #     f.close
  #   end
  def self.create_file(basename)
    fn = unique_filename basename

    # Yield out to the block
    f = File.new(filename_to_path(fn), "w")
    yield f

    f.close unless f.closed?

    # Build a Download object and return it
    Download.create({ :filename => fn })
  end

  # Get the filename for this download
  #
  # We save filenames in the database as relative paths, since the absolute
  # paths may change over time across Capistrano deployments.  This function
  # wraps the query of the filename variable and converts it to an absolute
  # path.
  #
  # @raise [RecordInvalid] if the filename is missing (validates :presence)
  # @raise [RecordInvalid] if the filename has invalid characters (validates :format, only [A-Za-z.-_] permitted)
  #
  # @api public
  # @return [String] this download's filename
  # @example Open this file for reading
  #   dl = Download.find(...)
  #   File.open(dl.filename) do |f|
  #     ...
  #     f.close
  #   end
  def filename
    return nil unless filename?
    Download.filename_to_path(read_attribute(:filename))
  end

  # Send this download to the user
  #
  # This function does its best to guess the MIME type by looking at the file
  # extension.
  #
  # @api public
  # @param [ActionController] controller The controller to use
  # @return [undefined]
  # @example Send this file to the user from controller method
  #   f = current_user.downloads.find_by_id('1')
  #   f.send_file(self)
  def send_file(controller)
    ext = File.extname(filename)[1..-1]
    mime_type = Mime::Type.lookup_by_extension(ext)
    content_type = mime_type.to_s unless mime_type.nil?
    content_type ||= 'text/plain'

    controller.send_file(filename,
      :x_sendfile => true,
      :type => content_type)
  end

  private

  # Get the path to a new download file
  #
  # This function will fetch a path for the file +basename+ in the downloads
  # folder (do not put a path of any sort on +basename+).  A unique
  # timestamp will be appended to the filename.
  #
  # @api private
  # @param basename [String] the base name of the file to create
  # @return [String] the name of the file
  def self.unique_filename(basename)
    ext = File.extname(basename)
    base = File.basename(basename, ext)

    # Add a timestamp to the basename
    timestamp = Time.now.utc.strftime('-%Y%m%d%H%M%S')
    ret = base + timestamp + ext
    fn = filename_to_path(ret)

    i = 0
    while File.exists? fn
      i = i + 1
      ret = base + timestamp + i.to_s + ext
      fn = filename_to_path(ret)

      # Runaway loop counter (DoS?)
      raise StandardError, "Cannot find a filename for download" if i == 100
    end

    ret
  end

  # Convert a filename to an absolute path
  # @api private
  # @param [String] fn relative filename
  # @return [String] absolute file path
  def self.filename_to_path(fn)
    Rails.root.join('downloads', fn)
  end

  # Delete the file when the database record is destroyed
  #
  # Just ignore if the file delete fails and raises an error.  We'll have to
  # manually clean the downloads directory in that case.
  #
  # @api private
  # @return [undefined]
  def delete_file
    File::delete(filename) rescue nil
  end
end
