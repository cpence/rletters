
module Users
  # An override of Devise's registrations controller
  class RegistrationsController < Devise::RegistrationsController
    # Create a new user object
    #
    # We override this method in order to set some default parameters that
    # are only available at the time of the request.
    #
    # @return [void]
    def new
      # Override the default value for language, if the user has set one in
      # their browser
      loc = http_accept_language.compatible_language_from(I18n.available_locales)

      build_resource(language: loc)
      respond_with resource
    end
  end
end
