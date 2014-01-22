# -*- encoding : utf-8 -*-

def double_rsolr_facets
  [double(name: 'authors_facet',
          items: [double(name: 'A. One', hits: 1),
                  double(name: 'B. Two', hits: 1)]),
   double(name: 'journal_facet',
          items: [double(name: 'Journal', hits: 1)])]
end

def double_rsolr_facet_queries
  { 'year:[* TO 1799]' => 0,
    'year:[1800 TO 1809]' => 0,
    'year:[1810 TO 1819]' => 0,
    'year:[1820 TO 1829]' => 0,
    'year:[1830 TO 1839]' => 0,
    'year:[1840 TO 1849]' => 0,
    'year:[1850 TO 1859]' => 0,
    'year:[1860 TO 1869]' => 0,
    'year:[1870 TO 1879]' => 0,
    'year:[1880 TO 1889]' => 0,
    'year:[1890 TO 1899]' => 0,
    'year:[1900 TO 1909]' => 0,
    'year:[1910 TO 1919]' => 0,
    'year:[1920 TO 1929]' => 0,
    'year:[1930 TO 1939]' => 0,
    'year:[1940 TO 1949]' => 0,
    'year:[1950 TO 1959]' => 0,
    'year:[1960 TO 1969]' => 0,
    'year:[1970 TO 1979]' => 0,
    'year:[1980 TO 1989]' => 0,
    'year:[1990 TO 1999]' => 0,
    'year:[2000 TO 2009]' => 0,
    'year:[2010 TO *]' => 1 }
end
