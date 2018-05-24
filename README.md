# RLetters

[![Build Status][travis_img]][travis] [![Code Metrics][codeclimate_img]][codeclimate] [![Test Coverage][coverage_img]][coverage] [![Inline docs][inch_img]][inch]
[![External API Docs][apiary_img]][apiary] [![Code Docs][rubydoc_img]][rubydoc]

[travis]: https://travis-ci.org/rletters/rletters
[travis_img]: https://travis-ci.org/rletters/rletters.svg?branch=master
[codeclimate]: https://codeclimate.com/github/rletters/rletters
[codeclimate_img]: https://codeclimate.com/github/rletters/rletters/badges/gpa.svg
[coverage]: https://codeclimate.com/github/rletters/rletters/coverage
[coverage_img]: https://codeclimate.com/github/rletters/rletters/badges/coverage.svg
[inch]: http://inch-ci.org/github/rletters/rletters
[inch_img]: http://inch-ci.org/github/rletters/rletters.svg?branch=master
[apiary]: http://docs.rletters.apiary.io/
[apiary_img]: http://img.shields.io/badge/api%20docs-apiary-brightgreen.svg
[rubydoc]: http://rubydoc.info/github/rletters/rletters
[rubydoc_img]: http://img.shields.io/badge/code%20docs-rubydoc-brightgreen.svg

**Homepage:** [http://rletters.net](http://rletters.net)  
**Git:** [http://github.com/rletters/rletters](http://github.com/rletters/rletters)  
**Author:** Charles Pence  
**Contributors:** See Contributors section below  
**Copyright:** &copy; 2014–2018 Charles Pence and the RLetters Team  
**License:** MIT License  
**Latest Released Version:** v3.0  
**Release Date:** May 24, 2018  

(*Note:* This README file describes the unreleased Git version, not the last release, which may be different. Select the appropriate release tag at the top left to see the README for the version you're using.)

RLetters is an application designed to let users perform complex searches as well as digital-humanities and text-mining analysis tasks on a corpus of journal articles.

## Features

### Text analysis

RLetters allows users to save the results of a given search as a "dataset."  This produces a saved record that users can return to later in order to perform text analysis tasks.

While text analysis tasks are a current area of active development in RLetters, currently the following are available:

-   Compute term frequency information (for single words or multiple-word phrases)
-   Compare word usage in two different datasets
-   Graph dataset by publication date
-   Determine statistically significant pairs of words (collocations) or associations between words at distance (cooccurrences)
-   Compute network of words used around a focal word
-   Extract references to proper names (locations, people, organizations)
-   Export dataset as citations in a variety of formats

### Complex search

The Solr backend on which RLetters is based allows for a number of complicated searching operations:

-   Searching on the basis of particular fields ("year:2010", "authors:Johnson", or "title:fish")
-   Boolean operators ("darwin OR huxley")
-   Wildcard search ("*fish" or "wom?n")
-   Text stemming ("evolution" matching "evolutionary" or "evolutionist")
-   Fuzzy matching (matching words similar to the requested term)
-   Proximity searching (two terms within N words of one another)

### Support for web and library standards

RLetters features a [JSON API to return search results](http://docs.rletters.apiary.io/) to other services around the internet.  We also provide support for the following web and library standards:

-   [unAPI](http://unapi.info) for automatic bibliographic data retrieval from individual documents
-   [WorldCat OpenURL Registry](http://www.oclc.org/developer/services/worldcat-registry) for detection of the OpenURL resolver of the user's local library

And you can export bibliographic data in the following standard formats:

-   [MARC 21 transmission format](http://www.loc.gov/marc/)
-   [MARCXML](http://www.loc.gov/standards/marcxml/)
-   [MARC-JSON (draft)](http://www.oclc.org/developer/content/marc-json-draft-2010-03-11)
-   [MODS](http://www.loc.gov/standards/mods/)
-   [RDF/XML](http://www.w3.org/TR/rdf-syntax-grammar/) (using [Dublin Core Grammar](http://dublincore.org/documents/dc-citation-guidelines/))
-   [RDF/N3](http://www.w3.org/DesignIssues/Notation3.html) (using [Dublin Core Grammar](http://dublincore.org/documents/dc-citation-guidelines/))
-   [BibTeX](http://www.ctan.org/pkg/bibtex)
-   [EndNote (ENW format)](http://www.endnote.com/)
-   [Reference Manager (RIS format)](http://www.refman.com/support/risformat_intro.asp)

### Cutting-edge development and maintenance tools

RLetters doesn't leave your developers out in the cold, either.  We've got speedy deployments on [Heroku,](https://www.heroku.com/) and our code has a thorough test suite and adheres to a probably unnecessary level of linting and style-guide fanaticism.

Visit [the website](https://www.rletters.net/) for more developer information, especially our [deployment guide.](https://www.rletters.net/dev/heroku.html)

## Contributors / Support

Special thanks to all contributors to the code here on GitHub. A full list of contributors including their patches can be found at:

<https://github.com/rletters/rletters/contributors>

We also have received the help of a great community of translators at [Transifex.](https://www.transifex.com/projects/p/rletters/)  Thanks especially to Alejandro León Aznar.

Also, several features of RLetters wouldn't be possible without the excellent work of other Ruby programmers.  Thanks in particular to those behind [Ansible,](http://www.ansibleworks.com/) [RSolr](https://github.com/mwmitchell/rsolr) and [RSolr::Ext](https://github.com/mwmitchell/rsolr-ext), and [bibtex-ruby](https://github.com/inukshuk/bibtex-ruby).  The stop lists found in `lib/r_letters/analysis/stop_list` are released under the BSD license by the Apache Solr project.  The colors in `lib/r_letters/visualization/color_brewer` are released by [the ColorBrewer project](http://www.colorbrewer.org) under the Apache license.

Charles Pence and Grant Ramsey were supported in the development of RLetters by the [National Science Foundation](http://www.nsf.gov), #1456573, and the [National Evolutionary Synthesis Center (NESCent),](http://www.nescent.org) NSF #EF-0905606.

[![National Science Foundation][nsf_img]][nsf] [![National Evolutionary Synthesis Ceter][nescent_img]][nescent]

[nsf]: http://www.nsf.gov
[nsf_img]: http://rletters.net/images/nsf.gif
[nescent]: http://nescent.org
[nescent_img]: http://rletters.net/images/nescent.png

## Copyright ##

RLetters &copy; 2011–2018 [Charles Pence](mailto:charles@charlespence.net). RLetters is licensed under the MIT license. Please see the {file:COPYING} document for more information.

