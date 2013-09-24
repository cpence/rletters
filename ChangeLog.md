# RLetters ChangeLog


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
