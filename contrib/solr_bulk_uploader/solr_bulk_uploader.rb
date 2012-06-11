#!/usr/bin/env ruby

if RUBY_PLATFORM != "java"
  puts "solr_bulk_uploader: You must run the bulk uploader using JRuby!"
  exit
end

bad_args = false
recursive = false
javabin = false
url = 'http://localhost:8080/solr'
reader_threads = 2
writer_threads = 2

if ARGV.include?('-r') || ARGV.include?('--recursive')
  ARGV.delete('-r')
  ARGV.delete('--recursive')
  recursive = true
end
if ARGV.include?('-j') || ARGV.include?('--javabin')
  ARGV.delete('-j')
  ARGV.delete('--javabin')
  javabin = true
end

index = ARGV.index { |a| a == '-u' || a == '--url' }
unless index.nil?  
  url = ARGV[index + 1]
  bad_args = true if url.nil?

  ARGV.delete_at(index + 1)
  ARGV.delete_at(index)
end

index = ARGV.index('--reader-threads')
unless index.nil?
  reader_threads = ARGV[index + 1]
  if reader_threads.nil?
    bad_args = true
  else
    reader_threads = Integer(reader_threads)
  end

  ARGV.delete_at(index + 1)
  ARGV.delete_at(index)
end

index = ARGV.index('--writer-threads')
unless index.nil?
  writer_threads = ARGV[index + 1]
  if writer_threads.nil?
    bad_args = true
  else
    writer_threads = Integer(writer_threads)
  end
  ARGV.delete_at(index + 1)
  ARGV.delete_at(index)
end

if ARGV.count != 0 || bad_args || ARGV.include?('-h') || ARGV.include?('--help')
  puts <<-EOF
Usage: solr_bulk_uploader [OPTION]...
Upload many XML documents to a Solr server using efficient JRubyisms.

Options:
  -r, --recursive       search for XML files in this and subdirectories
  -j, --javabin         upload in javabin format (must be enabled in
                        Solr configuration

  -u <url>, --url <url> the URL for the Solr server (default:
                        http://localhost:8080/solr)

  --reader-threads <n>  the number of XML-reading threads to spawn
                        (default: 2)
  --writer-threads <n>  the number of Solr writing threads to spawn
                        (default: 2)
EOF
  exit
end

require 'rubygems'
require 'nokogiri'
require 'jruby_threach'
require 'jruby_streaming_update_solr_server'

if recursive
  match_pattern = '**/*.xml'
else
  match_pattern = '*.xml'
end

suss = StreamingUpdateSolrServer.new(url, 10, writer_threads)

Dir.glob(match_pattern).threach(reader_threads) do |filename|
  f = File.open(filename)
  xml = Nokogiri::XML(f) do |config|
    config.noerror.noent.noblanks
  end
  f.close

  solr_doc = SolrInputDocument.new
  xml_doc = xml.root.first_element_child
  xml_doc.children.each do |child|
    if child.name != 'field'
      puts child.name
      warn 'A non-field element found in a document'
      next
    end
    unless child.has_attribute? 'name'
      warn 'A field without name found in a document'
      next
    end

    solr_doc[child.get_attribute('name')] = child.text
  end

  suss.add solr_doc
end

suss.commit
