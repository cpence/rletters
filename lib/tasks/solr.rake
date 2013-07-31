# -*- encoding : utf-8 -*-

def get_solr_path
  # Cache this response if we can
  return $example_path if $example_path

  # Try to get the path to the Solr checkout (look in ../solr, ./solr, and
  # the SOLR_EXAMPLE_PATH environment variable)
  if ENV['SOLR_EXAMPLE_PATH']
    $example_path = ENV['SOLR_EXAMPLE_PATH']
  elsif File.exist? File.join(getwd, 'solr', 'solr.war')
    $example_path = File.join(getwd, 'solr')
  elsif File.exist? File.join(getwd, '..', 'solr', 'solr.war')
    $example_path = File.join(getwd, '..', 'solr')
  else
    # Nope, we give up
    puts 'ERROR: Cannot locate Solr example; provide path in SOLR_EXAMPLE_PATH'
    exit 1
  end

  $example_path
end

namespace :solr do
  task :start do
    Dir.chdir get_solr_path do
      `start`
    end
  end
  
  task :stop do
    Dir.chdir get_solr_path do
      `stop`
    end
  end
end