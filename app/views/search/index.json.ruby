ret = { 'results' => { 'num_hits' => @result.num_hits } }

if @result.solr_response.dig('responseHeader', 'params')
  ret['results']['solr_params'] = @result.solr_response['responseHeader']['params']
end

if @result.facets&.all&.present?
  ret['results']['facets'] = @result.facets.all.map do |f|
    {
      'field' => f.field,
      'value' => f.value,
      'query' => f.query,
      'hits' => f.hits
    }
  end
end

ret['results']['documents'] = @result.documents.map do |d|
  {
    'uid' => d.uid,
    'doi' => d.doi,
    'license' => d.license,
    'license_url' => d.license_url,
    'data_source' => d.data_source,
    'title' => d.title,
    'journal' => d.journal,
    'year' => d.year,
    'volume' => d.volume,
    'number' => d.number,
    'pages' => d.pages,
    'authors' => d.authors.map do |a|
      {
        'full' => a.full,
        'first' => a.first,
        'last' => a.last,
        'prefix' => a.prefix,
        'suffix' => a.suffix
      }
    end
  }
end

ret.to_json
