# -*- encoding : utf-8 -*-

# Search and browse the document database
#
# This controller displays both traditional and advanced search pages, the
# resulting lists of documents, and also handles the detailed display of
# information about a single document.  Its main function is to convert the
# user's provided search criteria into Solr queries for 
# +Document.find_all_by_solr_query+.
#
# @see Document
# @see Document.find_all_by_solr_query
class SearchController < ApplicationController
  
  # Show the main search index page
  #
  # The controller just passes the search parameters through 
  # +search_params_to_solr_query+, then sends this solr query on to the
  # server using +Document.find_all_by_solr_query+.
  #
  # @api public
  # @return [undefined]
  def index
    # Treat 'page' and 'per_page' separately
    @page = 0
    @page = Integer(params[:page]) if params.has_key? :page
    @page = 0 if @page < 0

    @per_page = 10
    @per_page = @user.per_page if @user
    @per_page = Integer(params[:per_page]) if params.has_key? :per_page
    @per_page = 0 if @per_page < 0
    @per_page = 100 if @per_page > 100
    
    offset = @page * @per_page
    limit = @per_page
    
    # Default sort to relevance if there's a search, otherwise title
    if params[:precise] or params[:q]
      @sort = 'score desc'
    else
      @sort = 'year_sort desc'
    end
    @sort = params[:sort] if params.has_key? :sort

    # Expose the precise Solr search so we can use it to create datasets
    solr_query = search_params_to_solr_query(params)
    @solr_q = solr_query[:q]
    @solr_qt = solr_query[:qt]
    @solr_fq = solr_query[:fq]

    # Get the documents
    @documents = Document.find_all_by_solr_query(solr_query,
      :sort => @sort, :offset => offset, :limit => limit)
  end
  
  # Show the advanced search page
  #
  # @api public
  # @return [undefined]
  def advanced; end
  
  # Show or export an individual document
  #
  # This action is content-negotiated: if you request the page for a document
  # with any of the MIME types specified in +Document.serializers+, you 
  # will get a citation export back, as a download.
  #
  # @api public
  # @return [undefined]
  def show
    @document = Document.find(params[:id])

    respond_to do |format|
      format.html { render }
      format.any(*Document.serializers.keys) { 
        f = Document.serializers[request.format.to_sym]
        send_file f[:method].call(@document), "export.#{request.format.to_sym.to_s}", request.format.to_s
        return
      }
      format.any { render(:file => Rails.root.join('public', '404.html'), :layout => false, :status => 406) and return }
    end
  end

  # Add a single document to an existing dataset
  # @api public
  # @return [undefined]
  def add
    raise ActiveRecord::RecordNotFound unless @user
    
    @document = Document.find(params[:id])
    @datasets = @user.datasets

    render :layout => 'dialog'
  end
  
  # Redirect to the Mendeley page for a document
  # @api public
  # @return [undefined]
  def to_mendeley
    raise ActiveRecord::RecordNotFound if APP_CONFIG['mendeley_key'].blank?
    
    @document = Document.find(params[:id])
    
    begin
      res = Net::HTTP.start("api.mendeley.com") { |http| 
        http.get("/oapi/documents/search/title%3A#{URI.escape(@document.title)}/?consumer_key=#{APP_CONFIG['mendeley_key']}") 
      }
      json = res.body
      result = JSON.parse(json)
    
      mendeley_docs = result["documents"]
      raise ActiveRecord::RecordNotFound unless mendeley_docs.size
    
      redirect_to mendeley_docs[0]["mendeley_url"]
    rescue StandardError, Timeout::Error
      raise ActiveRecord::RecordNotFound
    end
  end
  
  # Redirect to the Citeulike page for a document
  # @api public
  # @return [undefined]
  def to_citeulike
    @document = Document.find(params[:id])

    begin
      res = Net::HTTP.start("www.citeulike.org") { |http| 
        http.get("/json/search/all?per_page=1&page=1&q=title%3A%28#{CGI::escape(@document.title)}%29")
      }
      json = res.body
      cul_docs = JSON.parse(json)

      raise ActiveRecord::RecordNotFound unless cul_docs.size

      redirect_to cul_docs[0]["href"]
    rescue StandardError, Timeout::Error
      raise ActiveRecord::RecordNotFound
    end
  end

  private

  # Convert from search parameters to Solr query parameters
  #
  # This function takes the GET parameters passed in to the search and
  # handles converting them to the query format expected by Solr.  Primarily,
  # it is intended to support the advanced search page.
  #
  # @api private
  # @param [Hash] params the Rails params object
  # @return [Hash] Solr-format query parameters
  # @example Convert an advanced search to Solr format
  #   search_params_to_solr_query({ :precise => 'true', :title => 'test' })
  #   # { :qt => 'precise', :q => 'title:(test)' }
  def search_params_to_solr_query(params)
    # Remove any blank values (you get these on form submissions, for
    # example)
    params.delete_if { |k, v| v.blank? }

    # Initialize by copying over the faceted-browsing query
    query_params = {}
    query_params[:fq] = params[:fq] unless params[:fq].nil?
        
    if params.has_key? :precise
      q_array = []
      
      # Advanced search, step through the fields
      query_params[:qt] = 'precise'
      q_array << "#{params[:q]}" unless params[:q].blank?
      
      # Verbatim search fields
      %W(volume number pages).each do |f|
        q_array << "#{f}:(#{params[f.to_sym]})" unless params[f.to_sym].blank?
      end

      # Verbatim or fuzzy search fields
      %W(title journal fulltext).each do |f|
        field = f
        field += "_stem" if params[(f + "_type").to_sym] and params[(f + "_type").to_sym] == "fuzzy"
        q_array << "#{field}:(#{params[f.to_sym]})" unless params[f.to_sym].blank?
      end
      
      # Handle the authors separately, for splitting support (authors search
      # is an AND search, not an OR search)
      unless params[:authors].blank?
        authors = params[:authors].split(',').map { |a| "#{NameHelpers.name_to_lucene(a.strip)}" }
        authors_str = authors.join(" AND ")
        
        q_array << "authors:(#{authors_str})"
      end

      # Handle the year separately, for range support
      unless params[:year_ranges].blank?
        # Strip whitespace, split on commas
        ranges = params[:year_ranges].gsub(/\s/u, '').split(',')
        year_queries = []
        
        ranges.each do |r|
          if r.include? '-'
            range_years = r.split('-')
            next unless range_years.count == 2
            next if range_years[0].match(/\A\d+\z/u) == nil
            next if range_years[1].match(/\A\d+\z/u) == nil
            
            year_queries << "[#{range_years[0]} TO #{range_years[1]}]"
          else
            next if r.match(/\A\d+\z/u) == nil
            
            year_queries << r
          end
        end
        
        unless year_queries.empty?
          q_array << "year:(#{year_queries.join(" OR ")})"
        end
      end

      # If there's no query after that, add the all-documents operator
      if q_array.empty?
        query_params[:q] = "*:*"
      else
        query_params[:q] = q_array.join(" AND ")
      end
    else
      # Simple search
      unless params.has_key? :q
        query_params[:q] = "*:*"
        query_params[:qt] = "precise"
      else
        query_params[:q] = params[:q]
        query_params[:qt] = "standard"
      end
    end
    
    query_params
  end

  # Send the given string content to the browser as a file download
  #
  # @api private
  # @param [String] str content to send to the browser
  # @param [String] filename filename for the downloaded file
  # @param [String] mime MIME type for the content
  # @return [undefined]
  def send_file(str, filename, mime)
    headers["Cache-Control"] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
    headers["Expires"] = "0"
    send_data str, :filename => filename, :type => mime, :disposition => 'attachment'
  end
end
