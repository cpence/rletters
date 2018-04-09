
# The environment variables that should be shown on the administration
# dashboard
ENVIRONMENT_VARIABLES_TO_PRINT = [
  # Our configuration
  'APP_NAME', 'APP_EMAIL',
  'DATABASE_URL', 'SOLR_URL', 'SOLR_TIMEOUT',
  'NLP_TOOL_PATH', 'GOOGLE_ANALYTICS_KEY',

  'MAIL_DOMAIN', 'MAIL_DELIVERY_METHOD', 'MAILGUN_API_KEY',
  'MANDRILL_API_KEY', 'POSTMARK_API_KEY', 'SENDGRID_API_USER',
  'SENDGRID_API_KEY', 'SENDMAIL_LOCATION', 'SENDMAIL_ARGUMENTS',
  'SMTP_ADDRESS', 'SMTP_PORT', 'SMTP_DOMAIN', 'SMTP_USERNAME',
  'SMTP_PASSWORD', 'SMTP_AUTHENTICATION', 'SMTP_ENABLE_STARTTLS_AUTO',
  'SMTP_OPENSSL_VERIFY_MODE',

  'VERBOSE_LOGS',
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

    if @model.admin_configuration[:tree]
      @collection = @model.roots
      render :collection_tree
    else
      @collection = @model.all
      render
    end
  end

  # Make a batch editing change to the entire collection
  #
  # The `:bulk_action` parameter should be set to one of the permissible bulk
  # actions. Currently these are:
  # - `:delete` - If this is set, then `params[:ids]` should be set to a JSON
  #   array of IDs to be deleted.
  # - `:tree` - If this is set, then `params[:tree]` should be set to a JSON
  #   array of hashes for root elements, each of which contains an ID and
  #   possibly an array of children. The format should be like that output by
  #   the Nestable jQuery plugin:
  #   ```
  #   [{"id":1},{"id":2},{"id":3,"children":[{"id":4},{"id":5}]}]
  #   ```
  #
  # @return [void]
  def collection_edit
    get_model

    bulk_action = (params[:bulk_action] || 'missing').to_sym
    case bulk_action
    when :delete
      return head(:forbidden) if @model.admin_configuration[:no_delete]
      return head(:unprocessable_entity) unless collection_edit_delete
    when :tree
      return head(:forbidden) if @model.admin_configuration[:no_edit]
      return head(:unprocessable_entity) unless collection_edit_tree
    else
      return head(:unprocessable_entity)
    end

    redirect_to admin_collection_path(params[:model])
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
    return head(:forbidden) if @model.admin_configuration[:no_create]

    @item = @model.new
  end

  # Create an item and add it to the collection
  #
  # @return [void]
  def item_create
    get_model
    return head(:forbidden) if @model.admin_configuration[:no_create]

    @item = @model.new
    if @item.update_attributes(item_params)
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
    return head(:forbidden) if @model.admin_configuration[:no_edit]

    @item = @model.find(params[:id])
  end

  # Update an item in the collection
  #
  # @return [void]
  def item_update
    get_model
    return head(:forbidden) if @model.admin_configuration[:no_edit]

    @item = @model.find(params[:id])
    if @item.update_attributes(item_params)
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
    return head(:forbidden) if @model.admin_configuration[:no_delete]

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
    fail ArgumentError, "cannot find model #{model}" unless @model
    fail ActiveRecord::RecordNotFound if @model.admin_attributes.empty?
  end

  # Do the batch delete bulk action.
  #
  # @return [Boolean] false if a serious error has occurred, true otherwise
  def collection_edit_delete
    # Get the array of IDs to delete
    return false unless params[:ids]
    begin
      ids = JSON.parse(params[:ids])
    rescue JSON::ParserError
      return false
    end
    return false unless ids.is_a?(Array)
    return false if ids.empty?

    # Check to make sure each of these actually exists
    ids.each { |id| return false unless @model.exists?(id) }

    # Delete all of them
    @model.destroy(ids)
  end

  # Do the tree edit bulk action.
  #
  # @return [Boolean] false if a serious error has occurred, true otherwise
  def collection_edit_tree
    # Get the tree value and make sure it's looking good
    return false unless params[:tree]
    begin
      tree = JSON.parse(params[:tree])
    rescue JSON::ParserError
      return false
    end
    return false if tree.empty?

    tree.each_with_index do |node, i|
      # These are the roots, so they have nil parent_ids
      item = @model.find(node['id'])
      item.update(parent_id: nil, sort_order: i)

      collection_edit_tree_recurse(node) if node['children']
    end

    true
  end

  # Recurse through the tree, taking care of saving changes to the
  # hierarchy
  #
  # @return [void]
  def collection_edit_tree_recurse(node)
    node['children'].each_with_index do |child, i|
      item = @model.find(child['id'])
      item.update(parent_id: node['id'], sort_order: i)

      collection_edit_tree_recurse(child) if child['children']
    end
  end

  # Permit all the right parameters through the form
  #
  # @return parameter object (type?)
  def item_params
    hash_at_end = {}

    keys = @model.admin_attributes.map do |key, config|
      if config[:model]
        # Models are passed in as their IDs, not as the object itself
        :"#{key}_id"
      elsif config[:array]
        # Array parameters have to be specified as an options hash at the
        # end of the permit call
        hash_at_end[key] = []
        nil
      else
        key
      end
    end
    keys.compact!

    if hash_at_end.empty?
      params[:item].permit(*keys)
    else
      params[:item].permit(*keys, hash_at_end)
    end
  end
end
