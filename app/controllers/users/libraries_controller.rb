
module Users
  # Work with the library records belonging to a given user
  #
  # This controller is responsible for the handling of the library OpenURL
  # resolvers that users are allowed to link to their accounts.
  #
  # @see Library
  class LibrariesController < ApplicationController
    before_action :authenticate_user!

    # Display the list of the user's libraries
    #
    # @return [void]
    def index
      render layout: false
    end

    # Show the form for creating a new library link
    #
    # @return [void]
    def new
      @library = current_user.libraries.build
      render layout: false
    end

    # Show the form for editing a library link
    #
    # @return [void]
    def edit
      @library = current_user.libraries.find(params[:id])
      render layout: false
    end

    # Create a new library link in the database
    #
    # @return [void]
    def create
      @library = current_user.libraries.new(library_params)
      if @library.save
        redirect_to edit_user_registration_path,
                    flash: { success: I18n.t('users.libraries.create.success') }
      else
        render action: 'new', layout: false
      end
    end

    # Update the attributes of a library link in the database
    #
    # @return [void]
    def update
      @library = current_user.libraries.find(params[:id])

      if @library.update(library_params)
        current_user.libraries.reload
        redirect_to edit_user_registration_path,
                    flash: { success: I18n.t('libraries.update.success') }
      else
        render action: 'edit', layout: false
      end
    end

    # Delete a library link from the database
    #
    # @return [void]
    def destroy
      @library = current_user.libraries.find(params[:id])

      @library.destroy
      current_user.libraries.reload

      redirect_to edit_user_registration_path
    end

    # Query the list of available libraries from OCLC
    #
    # This function sets `@libraries` to the list of all available libraries
    # for the client's IP address, according to the WorldCat library database.
    #
    # @return [void]
    def query
      @libraries = []

      begin
        res = Net::HTTP.start('www.worldcat.org') do |http|
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
      rescue *Net::HTTP::EXCEPTIONS
        @libraries = []
      end

      render layout: false
    end

    private

    # Whitelist acceptable library parameters
    #
    # @return [ActionController::Parameters] acceptable parameters for
    #   mass-assignment
    def library_params
      params.require(:users_library).permit(:name, :url)
    end
  end
end
