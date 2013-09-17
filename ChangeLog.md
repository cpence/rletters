# RLetters ChangeLog


## Version 1.1 (beta, UNRELEASED)

*   The "plot dataset by date" job has been reworked.  It now graphs its results in a much prettier format, shows its data in a cleaner table, and also supports normalizing the absolute document counts to percentages, by dividing either by the number of documents in the entire corpus, or in another specific dataset.
*   The "single term vectors" analysis job has been removed, as everything that could reasonably be done by that job (and support for datasets of size larger than 1 document) can now be performed by the "word frequency" job.


## Version 1.0 (beta, 2013-09-08)

*   Full support for searching and faceted browsing
*   Analysis jobs:
    *   Export a dataset as citations in a variety of formats
    *   Plot the dates of publication for a dataset
    *   Export the contents of the term vectors array for a single document
    *   Compute word frequency information for a dataset
