
# The environment variables that should be shown on the administration
# dashboard
ENVIRONMENT_VARIABLES_TO_PRINT = [
  # Our configuration
  'APP_NAME', 'APP_EMAIL', 'APP_MAIL_DOMAIN',
  'DATABASE_URL', 'SOLR_URL', 'SOLR_TIMEOUT',
  'NLP_TOOL_PATH', 'GOOGLE_ANALYTICS_KEY',
  'VERBOSE_LOGS', 'MAILER_PREVIEWS',
  # Important/interesting Ruby information, if available
  'RBENV_VERSION', 'RUBYOPT', 'RUBYLIB', 'GEM_PATH', 'GEM_HOME',
  'BUNDLE_BIN_PATH', 'BUNDLE_GEMFILE',
  # Rails information
  'RACK_ENV', 'RAILS_ENV'
]

# The administrative backend for RLetters
#
# This controller handles display of the administration pages, which allow
# the site administrator to configure and modify a variety of settings and
# data.
class AdminController < ApplicationController
  before_action :authenticate_administrator!
  layout 'admin'

  # Show the administration dashboard
  #
  # @return [void]
  def index
    @config_vars = ENVIRONMENT_VARIABLES_TO_PRINT
    @corpus_size = RLetters::Solr::CorpusStats.new.size
    @ping = RLetters::Solr::Connection.ping
    @solr_info = RLetters::Solr::Connection.info
  end

  # Show the edit page for a collection of objects
  #
  # @return [void]
  def collection_index
    get_model

    @hint = I18n.t("admin.#{params[:model]}.hint_markdown", default: 'MISSING')
    if @hint == 'MISSING'
      @hint = I18n.t("admin.#{params[:model]}.hint", default: 'MISSING')
      @hint = nil if @hint == 'MISSING'
    else
      @hint = Kramdown::Document.new(@hint).to_html.html_safe
    end

    @collection = @model.all
  end

  # Show a single item from the collection
  #
  # @return [void]
  def item_index
    get_model
    @item = @model.find(params[:id])
  end

  # Show the form for building an item to add to the collection
  #
  # @return [void]
  def item_new
    get_model
    @item = @model.new
  end

  # Create an item and add it to the collection
  #
  # @return [void]
  def item_create
    get_model

    @item = @model.new
    if @item.update_attributes(params[:item].permit(*@model.admin_attributes.keys))
      redirect_to admin_collection_path(params[:model])
    else
      render :item_new
    end
  end

  # Show the form for editing an item in the collection
  #
  # @return [void]
  def item_edit
    get_model
    @item = @model.find(params[:id])
  end

  # Update an item in the collection
  #
  # @return [void]
  def item_update
    get_model

    @item = @model.find(params[:id])
    if @item.update_attributes(params[:item].permit(*@model.admin_attributes.keys))
      redirect_to admin_collection_path(params[:model])
    else
      render :item_edit
    end
  end

  # Delete a single item from the database
  #
  # @return [void]
  def item_delete
    get_model

    @item = @model.find(params[:id])
    @item.destroy

    redirect_to admin_collection_path(model: params[:model])
  end

  private

  # Set the @model variable to the requested model
  #
  # @return [void]
  def get_model
    @model = params[:model].camelize.constantize
    unless @model.respond_to?(:admin_attributes)
      fail ActiveRecord::RecordNotFound
    end
  end
end
