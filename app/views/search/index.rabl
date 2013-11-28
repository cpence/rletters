object @result => :results
attribute :num_hits

if @result.solr_response['responseHeader'] &&
   @result.solr_response['responseHeader']['params']
  node(:solr_params) { |m| @result.solr_response['responseHeader']['params'] }
end

child :documents, object_root: false do
  attributes :uid, :doi, :license, :license_url, :data_source,
             :authors, :title, :journal, :year, :volume,
             :number, :pages
end

child @result.facets.all, root: :facets, object_root: false do
  attribute :field, :value, :query, :hits
end if @result.facets && @result.facets.all.present?
