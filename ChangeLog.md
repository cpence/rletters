# RLetters ChangeLog

## Version 1.2 (beta, unreleased)

*   The entire user interface has been rewritten using the Foundation toolkit.
*   A new "Differentiate two datasets" job has been added, which will compare two datasets using the Craig Zeta algorithm.  This is the Zeta algorithm, originally introduced by John F. Burrows (Literary and Linguistic Computing, 22(1):27, 2007), as extended by Hugh Craig (Craig and Kinney, _Shakespeare, Computers, and the Mystery of Authorship,_ 2009) to generate both marker words and anti-marker words.
    *   Thanks to [David Hoover's analysis pages,](https://files.nyu.edu/dh3/public/TheZeta&IotaSpreadsheet.html) which were exceptionally useful in the implementation of this job.
    *   This analysis task compares the two requested datasets and returns a list of words for each that marks out a text as belonging to that dataset (words that make a document likely to appear in dataset A and words that make a document likely to appear in dataset B).
    *   It also produces a graph, showing the separation between these two sets of words.  It does so by looking at pieces of each of datasets A and B, and determining what fraction of the words in those pieces belong to the A-marker set and to the B-marker set, respectively.  If the analysis has succeeded, then this graph should appear as two clouds of distinct points, a set of A-dataset points and a set of B-dataset points, clearly delineated.
    *   Finally, it returns the "Zeta scores" of each of the 1,000 most common words in the datasets.  The highest possible Zeta score is 2.0 (indicating a "pure" A-marker word) and the lowest is 0.0 (indicating a "pure" B-marker word).
*   RLetters now can run on JRuby, and when running under JRuby the connection to the Stanford NLP package is native, by default.


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
