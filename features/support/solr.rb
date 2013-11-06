
# Activate bundled Solr server, if available
if File.exists? Rails.root.join('vendor', 'solr')
  Dir.chdir(Rails.root.join('vendor', 'solr')) do
    system(Rails.root.join('vendor', 'solr', 'start').to_s)
  end
end

at_exit do
  # Destroy Solr server
  if File.exists? Rails.root.join('vendor', 'solr')
    system(Rails.root.join('vendor', 'solr', 'stop').to_s)
  end
end
