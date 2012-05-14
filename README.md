# RLetters #

[![Still Maintained][sm_img]][sm] [![Build Status][travis_img]][travis]

[sm]: http://stillmaintained.com/cpence/rletters
[sm_img]: http://stillmaintained.com/cpence/rletters.png
[travis]: http://travis-ci.org/cpence/rletters
[travis_img]: https://secure.travis-ci.org/cpence/rletters.png?branch=master

**Homepage:** [http://charlespence.net/rletters](http://charlespence.net/rletters})  
**Git:** [http://github.com/cpence/rletters](http://github.com/cpence/rletters)  
**Author:** Charles Pence  
**Contributors:** See Contributors section below  
**Copyright:** 2011–2012  
**License:** MIT License  
**Latest Version:** (still in private beta)  
**Release Date:** (still in private beta)  

RLetters is an application designed to let users perform complex searches as well as digital-humanities and text-mining analysis tasks on a corpus of journal articles.

## Features ##

### Complex search ###

The Solr backend on which RLetters is based allows for a number of complicated searching operations:

-   Boolean operators ("darwin OR huxley")
-   Wildcard search ("*fish" or "wom?n")
-   Text stemming ("evolution" matching "evolutionary" or "evolutionist")
-   Fuzzy matching (matching words similar to the requested term)
-   Proximity searching (two terms within N words of one another)

### Text analysis ###

RLetters allows users to save the results of a given search as a "dataset."  This produces a saved record that users can return to later in order to perform text analysis tasks.

While text analysis tasks are a current area of active development in RLetters, currently the following are available:

-   Graph dataset by year
-   Export dataset as citations in a variety of formats
-   Show complete table of term frequency information (for datasets consisting of a single document)

### Support for web and library standards ###

RLetters provides support for the following web and library standards:

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

### Cutting-edge development and maintenance tools ###

RLetters doesn't leave your developers out in the cold, either.  We've got support for the following features that make development, deployment, maintenance, and monitoring easier:

-   All deployment (and even much of the configuration) handled automatically by [Capistrano](https://github.com/capistrano/capistrano/)
-   Track page views with [Google Analytics](http://google.com/analytics)
-   Source well-documented using [Yard](http://yardoc.org)
-   Continuous integration support with [Travis](http://travis-ci.org/)
-   Baked-in support for error reporting using [Airbrake](http://airbrake.io/) (account registration required)


## Installation / Deployment ##

See our detailed [installation and deployment](https://github.com/cpence/rletters/wiki/Installation-and-Deployment) guide for instructions.  For the extremely impatient:

    ssh SERVER_URL
        # Install Solr, Ruby, Apache, Passenger
        exit
    git clone git://github.com/cpence/rletters.git
    cd rletters
    cp config/deploy/deploy_config.rb.dist config/deploy/deploy_config.rb
    $EDITOR config/deploy/deploy_config.rb
    # Set server URLs, deployment path
    cap deploy:setup
    # Answer all the questions
    cap deploy:check
    cap deploy:update
    ssh SERVER_URL
        cd DEPLOYMENT_PATH
        rake RAILS_ENV=production db:schema:load
        $EDITOR /etc/apache2/apache2.conf
        # Add appropriate stanza for DEPLOYMENT_PATH
        exit
    cap deploy:start

## Contributors ##

Special thanks to all contributors for submitting patches. A full list of
contributors including their patches can be found at: 

https://github.com/cpence/rletters/contributors

Also, several features of RLetters wouldn't be possible without the excellent work of other Ruby programmers.  Thanks in particular to those behind [RSolr](https://github.com/mwmitchell/rsolr) and [RSolr::Ext](https://github.com/mwmitchell/rsolr-ext), [citeproc-ruby](https://github.com/inukshuk/citeproc-ruby), and [bibtex-ruby](https://github.com/inukshuk/bibtex-ruby).


## Copyright ##

RLetters &copy; 2011–2012 by [Charles Pence](mailto:charles@charlespence.net). RLetters is licensed under the MIT license. Please see the {file:COPYING} document for more information.

