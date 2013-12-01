## Analyze collocations

#### This analysis job finds a list of statistically significant pairs of words.

In natural language processing, a [collocation](https://en.wikipedia.org/wiki/Collocation) is a statistically significant association between a pair of words.  For example, while English speakers use the phrases "strong tea" and "powerful computers," it would not be idiomatic English to use "powerful tea" or "strong computers."

This analysis task can use the following four different methods for determining significant pairs of words:

*   [Mutual information,](https://en.wikipedia.org/wiki/Mutual_information) which measures the extent to which being informed about the first of a pair of words provides information about the second member of the pair.
*   [One-tailed t-test,](https://en.wikipedia.org/wiki/Student's_t-test) which determines whether or not there is significant support for the hypothesis that a given pair of words is correlated over the null hypothesis that words are independently distributed.
*   [Log-likelihood ratio,](https://en.wikipedia.org/wiki/Likelihood_function) which compares the probability that the two words are independent with the probability that they are dependent.
*   [Frequency, biased by parts-of-speech,](http://nlp.stanford.edu/fsnlp/promo/colloc.pdf) which sorts bigrams and trigrams by their raw frequency counts, and then filters them according to their parts of speech.  [Justeson and Katz](http://dx.doi.org/10.1017/S1351324900000048) proposed a set of filters based on part-of-speech tagging that are likely to sort useful and interesting collocations from those that merely involve stop-words.  (Parts-of-speech tagging is performed by the [Stanford POS Tagger.](http://nlp.stanford.edu/software/tagger.shtml))  The parts-of-speech patterns which are kept are:
    *   Adjective Noun
    *   Noun Noun
    *   Adjective Adjective Noun
    *   Adjective Noun Noun
    *   Noun Adjective Noun
    *   Noun Noun Noun
    *   Noun Preposition Noun

The user can specify how many of the most significant collocations to preserve, and these are offered to the user for download.  This job can answer a variety of interesting questions:

> What concepts are often invoked together in a body of literature? *(Input: a domain of interest, selecting one of the first three analysis methods and then searching for concepts of interest)*
>
> What technical terms or phrases are often used in a discipline? *(Input: a domain of interest, selecting the parts-of-speech analysis method)*
