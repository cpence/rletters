# RLetters ChangeLog

## Version 3.0 (unreleased)

*   **Upgrade to bundling a more recent version of Solr (7.3.0).** This is a **significant and breaking change** for users, who *must* upgrade their Solr installations, as we are using some of the new features in later Solr versions to provide (in some cases dramatic) speed improvements. Reindexing content is not required, but is recommended when feasible.
*   **Upgrade to use features in contemporary Ruby (2.3.0+).** This is a **significant change** for users, who *must* upgrade their deployed version of Ruby.
*   Remove the Stanford NLP connection and replace it with pure-Ruby solutions. No more dependency on a functional NLP install and a JVM.
*   User data handling is now entirely compliant with the European Union's GDPR and cookie policies.
*   Site configuration is now edited via a `.env` file in the root directory of the project, or can be controlled via environment variables.
*   Features of the application can now be readily enabled and disabled using these environment variables.
*   Add support for sending application e-mails using a variety of different mail services, including Mandrill, Sendgrid, Postmark, and Mailgun, in addition to Rails' default Sendmail and SMTP support, and configure all these methods in the `.env` file.
*   Any particular type of analysis job can be disabled using a feature flag, should they cause problems on any server installation.
*   The interface can now be themed using themes from Bootswatch.
*   The main search interface has been slightly redesigned to include support for infinite scrolling and be more functional on mobile/tablet screens.
*   Datasets are now stored not as a list of entries, but as a list of the searches that were used to create them. This list of searches can be viewed on the dataset information page.
*   Iterate through datasets, no matter the size, much faster, using the cursor support present in Solr >= 4.8. This is a dramatic speed improvement especially for those installations using distributed or sharded Solr servers.
*   Add support for client-side, downloadable word cloud generation to the word frequency and Craig Zeta analysis jobs.
*   Allow all analysis tasks to potentially generate multiple output files, enabling enhanced visualizations.
*   Upgrade delayed job handling to use ActiveJob with DelayedJob using the database as backend, removing the need for a Redis server.
*   Fixed the broken progress reporting in the Craig Zeta job.
*   Fix bugs in the Article and Term Dates jobs such that the data would sometimes come out unsorted, producing jumbled graphs.
*   Fix a bug in the Word Frequency component that would cause it to fail if both n-gram-inclusion and n-gram-exclusion (or stop) lists were specified.
*   Remove mapping component from named entity job. The amount of geocoding that was being requested from Google Maps would require significant charges under the Maps API billing system.
*   Switch the web server component to Puma to avoid slow client attacks and take advantage of multithreading.
*   Integration testing (smoke tests) ported back to Rails system tests. Dramatically increased stability and maintainability.
*   Update language support.


## Version 2.0.1 (2015-01-12)

*   Fix a bug in cookie handling that would cause major problems for an extant 1.x site upgrading to 2.0.0.


## Version 2.0.0 (2015-01-01)

*   The fetch results page now shows progress updates for unfinished jobs, as well as live-updates.
    -   This also includes support for terminating all pending jobs, as well as terminating jobs while they're running.
*   The plot-dates task has been split into two analysis task types, one of which counts the number of articles in each year in the dataset, and one of which counts the number of occurrences of a particular term in the articles within a dataset, and graphs those occurrences by year.
*   There is now a cooccurrence analyzer that will return significant cooccurrences that occur at some distance from one another, as opposed to collocations, which are immediate neighbors.
*   Add a completely redesigned advanced search page, including autocomplete for authors and journals.
*   Add an optimized WordFrequencyAnalyzer that can be called when only a single block is requested.
*   The date-plotting jobs now include intervening years with a "zero" value in the downloaded CSV and graph, instead of leaving them out of the analysis entirely.
*   Several jobs now support returning "all words" or "all pairs" when practicable.
*   Fix several significant bugs in the collocation analyzer, including one that meant that most of the returned weighting values were incorrect.
*   Fix a significant bug in one of the frequency analyzers, which meant that the 'split across' user parameter was being ignored.
*   Fix a bug in the computation of DF values within datasets.
*   Fix a bug that shows the wrong status message when starting an analysis job.
*   Change the way in which RLetters communicates with the Stanford NLP Java package, increasing reliability of parts-of-speech tagging, lemmatization, and named entity extraction.
*   Fix a bug preventing the "normalize" mode from being activated in ArticleDates.
*   Fix a bug preventing stemming from being activated in the WordFrequencyAnalyzer.
*   Fix a bug in facet display code that could cause the facet display to cut off early.
*   UI refresh/rewrite to increase stability and reduce development time.
*   Update Rails, which fixes four potential DoS vulnerabilities.
*   Fix a potential DoS vulnerability from symbol conversion in the export code.
*   Update to Rails' internationalization means we can now be translated into Tamil, Khmer, and several more regional dialects of Spanish, among others.
    -   We have also updated our Unicode CLDR dataset to version 25, providing more recent data about pluralization and international language names.


## Version 1.2 (beta, 2013-12-24)

*   The entire user interface has been rewritten.
    *   This includes a new "workflow" mode, in which the user will be walked through the process of starting a new analysis, adding data to it, and collecting the results when it completes.
    *   The ability to manually start analysis tasks from the page for the dataset has been removed; the workflow controller is now the only way to start tasks.
*   A new "differentiate two datasets" job has been added, which will compare two datasets using the Craig Zeta algorithm.  This is the Zeta algorithm, originally introduced by John F. Burrows (Literary and Linguistic Computing, 22(1):27, 2007), as extended by Hugh Craig (Craig and Kinney, _Shakespeare, Computers, and the Mystery of Authorship,_ 2009) to generate both marker words and anti-marker words.
    *   Thanks to [David Hoover's analysis pages,](https://files.nyu.edu/dh3/public/TheZeta&IotaSpreadsheet.html) which were exceptionally useful in the implementation of this job.
    *   This analysis task compares the two requested datasets and returns a list of words for each that marks out a text as belonging to that dataset (words that make a document likely to appear in dataset A and words that make a document likely to appear in dataset B).
    *   It also produces a graph, showing the separation between these two sets of words.  It does so by looking at pieces of each of datasets A and B, and determining what fraction of the words in those pieces belong to the A-marker set and to the B-marker set, respectively.  If the analysis has succeeded, then this graph should appear as two clouds of distinct points, a set of A-dataset points and a set of B-dataset points, clearly delineated.
    *   Finally, it returns the "Zeta scores" of each of the 1,000 most common words in the datasets.  The highest possible Zeta score is 2.0 (indicating a "pure" A-marker word) and the lowest is 0.0 (indicating a "pure" B-marker word).
*   A new "collocation analysis" job has been added, which will look for statistically significantly associated pairs of words within a text.
    *   Statistical significance can be measured by any one of four different methods -- mutual information, a basic t-test, likelihood ratio, and a simple frequency-based count, culled by matching patterns in parts-of-speech usage.
    *   The user specifies the number of collocations to return, and they are downloadable in a CSV file.
*   A new "compute network of terms" job has been added, which renders the network of terms surrounding a given focal word.
    *   The network is drawn using D3 showing node degree and node connection strength.
    *   Results can be downloaded as a GraphML file for further analysis.
*   The "compute word frequency" job now supports analyzing multiple-word phrases (n-grams), in addition to single words.
*   The "compute word frequency" job now supports word stemming (fast) and full word lemmatization (slow).
*   RLetters now supports fetching the full text of documents from an external HTTP server.
*   Administrators of RLetters sites can now define custom categories of journals, and if these categories are defined, they are available for users to filter their search results.
*   More information is now available in the dropdown for each document, including the DOI, the document's license, and information about the data source for the document.
*   Datasets, while being created and destroyed, are now marked as disabled so that partially-completed datasets will not appear in the user interface.
*   Basic integration testing (essentially, smoke tests) added using Cucumber.


## Version 1.1 (beta, 2013-09-24)

*   A new "extract references to proper names" job has been added, based on the Named Entity Reference annotator offered by the Stanford Natural Language Project.
    *   Currently, there is integrated support for the NER's PERSON, ORGANIZATION, and LOCATION types.  PERSON and ORGANZIATION are expressed as lists of hits that link to a search for that entity on Wikipedia.  Locations can be displayed either as a list or as a map, using Google's geocoding support (which, while less than perfect, is better than nothing).
    *   The results can be downloaded as a CSV file, which contains all of the hits returned by the NER, without any editing.
*   The "compute word frequencies" job has new features.
    *   When creating blocks based on the number of words they contain, you can now choose what to do with the leftover words after the last block of size N.  You can combine them with the last block (to create a block of size >N), make them a block on their own (to create a block of size <N), you can discard them (truncating the document, removing those words from analysis), or you can choose to take *only* the first N words from each document, producing one block per document.
    *   You can specify a list of words, separated by spaces, such that word frequencies will only be collected for the words in the list (an "inclusion list").
    *   You can specify a list of words, separated by spaces, such that the word frequencies will *not* be collected for the words in the list (an "exclusion list").  You can also specify that word frequencies should not be collected for the most commonly occurring words in a variety of languages.
*   The "plot dataset by date" job has been reworked.  It now graphs its results in a much prettier format, shows its data in a cleaner table, and also supports normalizing the absolute document counts to percentages, by dividing either by the number of documents in the entire corpus, or in another specific dataset.
*   The "single term vectors" analysis job has been removed, as everything that could reasonably be done by that job (and support for datasets of size larger than 1 document) can now be performed by the "word frequency" job.


## Version 1.0 (beta, 2013-09-08)

*   Full support for searching and faceted browsing
*   Analysis jobs:
    *   Export a dataset as citations in a variety of formats
    *   Plot the dates of publication for a dataset
    *   Export the contents of the term vectors array for a single document
    *   Compute word frequency information for a dataset
