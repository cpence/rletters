
# Bulk Solr Upload Client

This directory holds a small client for bulk uploading files to your Solr
server.  To use it, you'll first need JRuby installed.  Then install the
following gems:

    jruby -S gem install nokogiri jruby_streaming_update_solr_server jruby_threach

The uploader can then be run with:

    jruby solr_bulk_uploader.rb

Pass the parameter `--help` for options, which will print the following help
message:

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

The `reader-threads` option sets how many threads will be used to read files
from disk and parse XML.  The `writer-threads` option will be passed to the
StreamingSolrUpdateServer class, and it sets how many threads will be used to
upload files to the Solr server.

Note that the `--javabin` parameter requires that the javabin handler has been enabled in your Solr configuration.  If it has, you should enable this, as it will be faster.  The following line should appear in your `solrconfig.xml`:

    <requestHandler name="/update/javabin" class="solr.BinaryUpdateRequestHandler" />

For more information, see the
[jruby_streaming_update_solr_server gem](https://github.com/billdueber/jruby_streaming_update_solr_server),
or the doocumentation
[for the StreamingUpdateSolrServer Java class.](https://lucene.apache.org/solr/api/org/apache/solr/client/solrj/impl/StreamingUpdateSolrServer.html)
