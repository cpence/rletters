# -*- encoding : utf-8 -*-

def grouped_solr_hash
  { 'grouped' => {
    'year' => {
      'matches' => 1043,
      'groups' => [
        { 'groupValue' => '2009', 'doclist' => { 'numFound' => 123 } },
        { 'groupValue' => '2007', 'doclist' => { 'numFound' => 456 } }
        ]
      }
    }
  }
end

def grouped_solr_hash_no_records
  { 'grouped' => {
    'year' => {
      'matches' => 1043,
      'groups' => []
      }
    }
  }
end
