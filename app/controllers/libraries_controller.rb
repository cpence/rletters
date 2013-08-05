# -*- encoding : utf-8 -*-

# Work with the library entries belonging to a given user
#
# This controller is responsible for the handling of the library OpenURL
# resolvers that users are allowed to link to their accounts.
#
# @see Library
class LibrariesController < ApplicationController
  before_filter :authenticate_user!

  # Display the list of the user's libraries
  #
  # This action is meant to be pulled in via AJAX, so it doesn't render a
  # layout.
  #
  # @api public
  # @return [undefined]
  def index
    @libraries = current_user.libraries
    render layout: false
  end

  # Show the form for creating a new library link
  # @api public
  # @return [undefined]
  def new
    @library = current_user.libraries.build
    render layout: 'dialog'
  end

  # Show the form for editing a library link
  # @api public
  # @return [undefined]
  def edit
    @library = current_user.libraries.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @library
    render layout: 'dialog'
  end

  # Show a confirmation form for deleting a library link
  # @api public
  # @return [undefined]
  def delete
    @library = current_user.libraries.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @library
    render layout: 'dialog'
  end

  # Create a new library link in the database
  # @api public
  # @return [undefined]
  def create
    @library = Library.new(library_params)
    @library.user = current_user

    if @library.save
      current_user.libraries.reload
      redirect_to edit_user_registration_path,
                  notice: I18n.t('libraries.create.success')
    else
      render action: 'new', layout: 'dialog'
    end
  end

  # Update the attributes of a library link in the database
  # @api public
  # @return [undefined]
  def update
    @library = current_user.libraries.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @library

    if @library.update_attributes(library_params)
      current_user.libraries.reload
      redirect_to edit_user_registration_path,
                  notice: I18n.t('libraries.update.success')
    else
      render action: 'edit', layout: 'dialog'
    end
  end

  # Delete a library link from the database
  # @api public
  # @return [undefined]
  def destroy
    @library = current_user.libraries.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @library

    if params[:cancel]
      redirect_to edit_user_registration_path
      return
    end

    @library.destroy
    current_user.libraries.reload

    redirect_to edit_user_registration_path
  end

  # Query the list of available libraries from OCLC
  #
  # This function sets +@libraries+ to the list of all available libraries
  # for the client's IP address, according to the WorldCat library database.
  #
  # @api public
  # @return [undefined]
  def query
    @libraries = []

    begin
      res = Net::HTTP.start('worldcatlibraries.org') do |http|
        http.get("/registry/lookup?IP=#{request.remote_ip}")
      end

      # We have to strip the namespaces from this XML, because the markup we
      # get from WorldCat often includes anonymous, unprefixed namespaces
      # on child elements, which drives Nokogiri absolutely crazy.
      doc = Nokogiri::XML::Document.parse(res.body).remove_namespaces!
      @libraries = doc.css('resolverRegistryEntry').map do |entry|
        { name: entry.at_css('institutionName').content,
          url: entry.at_css('resolver baseURL').content }
      end
    rescue StandardError, Timeout::Error
      @libraries = []
    end

    render layout: 'dialog'
  end

  private

  # Whitelist acceptable library parameters
  #
  # @return [ActionController::Parameters] acceptable parameters for
  #   mass-assignment
  def library_params
    params.require(:library).permit(:name, :url)
  end
end
