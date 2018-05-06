# frozen_string_literal: true

module Admin
  # Edit customizable content snippets
  class SnippetsController < ApplicationController
    before_action :authenticate_admin!
    layout 'admin'

    # Show all of the currently defined snippets
    #
    # @return [void]
    def index
    end

    # Show the form to create a new snippet
    #
    # @return [void]
    def new
      @snippet_list = snippet_list
      @snippet = Admin::Snippet.new

      render layout: false
    end

    # Create a new snippet
    #
    # @return [void]
    def create
      # There should be at least one snippet with this name, or else we have
      # a problem
      Admin::Snippet.find_by!(name: snippet_params[:name])

      snippet = Admin::Snippet.create(snippet_params)
      if snippet.save
        redirect_to snippets_path
      else
        redirect_to snippets_path, alert: I18n.t('admin.snippets.validation_error')
      end
    end

    # Show the edit form for an existing snippet
    #
    # @return [void]
    def edit
      @snippet_list = snippet_list
      @snippet = Admin::Snippet.find(params[:id])

      render layout: false
    end

    # Update the parameters of an existing snippet
    #
    # @return [void]
    def update
      snippet = Admin::Snippet.find(params[:id])
      snippet.update!(snippet_params)
      redirect_to snippets_path
    end

    # Delete a snippet, unless it's in English
    #
    # @return [void]
    def destroy
      snippet = Admin::Snippet.find(params[:id])
      fail ActionController::ParameterMissing, :language if snippet.language == 'en'

      snippet.destroy()

      redirect_to snippets_path
    end

    private

    # Return the list of acceptable snippet names
    #
    # @return [Hash] permissible snippet names, in a hash to make a form field
    def snippet_list
      Admin::Snippet.where(language: :en).each_with_object({}) do |s, ret|
        ret[s.friendly_name] = s.name
      end
    end

    # Whitelist acceptable snippet parameters
    #
    # @return [ActionController::Parameters] acceptable parameters for
    #   mass-assignment
    def snippet_params
      params.require(:admin_snippet).permit(:name, :language, :content)
    end
  end
end
