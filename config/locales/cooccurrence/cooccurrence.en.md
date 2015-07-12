## Analyze cooccurrences

#### This analysis job finds a list of statistically significant distant pairs of words.

In natural language processing, a [cooccurrence](https://en.wikipedia.org/wiki/Co-occurrence) is a statistically significant association between a pair of words, where those words need not appear immediately next to one another.  For example, paragraphs that often mention the United Nations will also likely mention the General Assembly or the Security Council.

(If you would like to determine statistically significant associations between words that are immediate neighbors, check out the collocation analysis.)

This task can use the following two different methods for determining significant cooccurrences:

*   [Mutual information,](https://en.wikipedia.org/wiki/Mutual_information) which measures the extent to which being informed about the first of a pair of words provides information about the second member of the pair.
*   [One-tailed t-test,](https://en.wikipedia.org/wiki/Student's_t-test) which determines whether or not there is significant support for the hypothesis that a given pair of words is correlated over the null hypothesis that words are independently distributed.

The user can specify the following parameters:

*   The word of interest -- the analysis will return significance values for *every* cooccurrence with this word.
*   How many of the most significant cooccurrences to preserve.
*   The window for which we will detect cooccurrences. The cooccurrence algorithm checks for significant correlations between words that occur within a particular distance. To emulate "phrase-level" cooccurrence, use a distance of 5 words. For "sentence-level" cooccurrence, try 20. For "paragraph-level" cooccurrence, use 200. The maximum distance is the article level -- set the distance to a large number to search for article-level cooccurrence.

Once the job is finished, the requested cooccurrences are offered to the user for download.  This job can answer a variety of interesting questions:

> What concepts are often invoked together in a body of literature? *(Input: a domain of interest, selecting one of the first three analysis methods and then searching for concepts of interest)*
