# -*- encoding : utf-8 -*-

# Work with the library entries belonging to a given user
#
# This controller is responsible for the handling of the library OpenURL
# resolvers that users are allowed to link to their accounts.
#
# @see Library
class LibrariesController < ApplicationController
  before_filter :login_required

  # Display the list of the user's libraries
  #
  # This action is meant to be pulled in via AJAX, so it doesn't render a
  # layout.
  #
  # @api public
  # @return [undefined]
  def index
    @libraries = @user.libraries
    render :layout => false
  end
  
  # Show the form for creating a new library link
  # @api public
  # @return [undefined]
  def new
    @library = @user.libraries.build
    render :layout => 'dialog'
  end

  # Show the form for editing a library link
  # @api public
  # @return [undefined]
  def edit
    @library = @user.libraries.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @library
    render :layout => 'dialog'
  end

  # Show a confirmation form for deleting a library link
  # @api public
  # @return [undefined]
  def delete
    @library = @user.libraries.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @library
    render :layout => 'dialog'
  end
  
  # Create a new library link in the database
  # @api public
  # @return [undefined]
  def create
    @library = Library.new(params[:library])
    @library.user = @user

    if @library.save
      @user.libraries.reload
      redirect_to user_path, :notice => I18n.t('libraries.create.success')
    else
      render :action => 'new', :layout => 'dialog'
    end
  end
  
  # Update the attributes of a library link in the database
  # @api public
  # @return [undefined]
  def update
    @library = @user.libraries.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @library
    
    if @library.update_attributes(params[:library])
      @user.libraries.reload
      redirect_to user_path, :notice => I18n.t('libraries.update.success')
    else
      render :action => 'edit', :layout => 'dialog'
    end
  end
  
  # Delete a library link from the database
  # @api public
  # @return [undefined]
  def destroy
    @library = @user.libraries.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @library
    
    redirect_to user_path and return if params[:cancel]

    @library.destroy
    @user.libraries.reload
    
    redirect_to user_path
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
      res = Net::HTTP.start("worldcatlibraries.org") { |http| 
        http.get("/registry/lookup?IP=#{request.remote_ip}") 
      }
      doc = REXML::Document.new res.body
      doc.elements.each('records/resolverRegistryEntry') do |entry|
        name = entry.elements['institutionName'].text
        url = entry.elements['resolver/baseURL'].text
        
        @libraries << { :name => name, :url => url }
      end
    rescue StandardError, Timeout::Error
      @libraries = []
    end
    
    render :layout => 'dialog'
  end
end
