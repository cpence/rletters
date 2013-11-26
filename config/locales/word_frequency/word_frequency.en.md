## Compute word frequency table

#### This analysis job computes a detailed table of word frequency information.

This job yields an incredibly detailed word frequency chart, customizable in a variety of ways.  You may choose any of the following methods to select a set of words you're interested in:

*   Analyze single words or phrases of more than one word (n-grams)
*   Take the N most frequently occurring words (or n-grams) in the dataset
*   For single words:
    *   Take an explicit list of words
    *   Remove from the list the most common words appearing in a variety of languages
    *   Remove from the list any words appearing in a given explicit list
*   For n-grams:
    *   Include only n-grams that contain certain words
    *   Exclude any n-grams that contain certain words

You may then choose to divide the text into segments, a common requirement for other analysis algorithms.  You can create these segments either by setting an explicit number of words, or by setting the number of blocks you would like to appear in the final result.  These blocks can either be produced within each individual journal article, or across journal article boundaries (i.e., segmented after the articles are concatenated into one large stream of text).

A variety of results are then reported.  Within each segmented block of text, you receive the following statistics for each word (or n-gram):

*   How many times that word appears within the block
*   That absolute count divided by the number of words within the block (i.e., the fraction of the block that this word constitutes)
*   [TF/IDF (term frequency-inverse document frequency)](https://en.wikipedia.org/wiki/Tf%E2%80%93idf) of this term within the dataset
*   TF/IDF of this term within the corpus as a whole (not available for n-grams)

You also can see the number of types and tokens for each segment.  And for the entire dataset, you receive the following statistics for each word:

*   How many times that word appears within the entire dataset
*   That absolute count divided by the number of words within the dataset (i.e., the fraction of the dataset that this word constitutes)
*   DF (document frequency) of this term within the entire corpus (i.e., the number of documents in the entire database in which this term appears; not available for n-grams)
*   TF/IDF of this term within the entire corpus (not available for n-grams)

In addition to supplying the raw input for a wide variety of textual analysis algorithms that the user can run on their own, this data can immediate answer a variety of interesting questions:

> How often are certain words used within a given dataset? *(Input: a domain of interest, looking at the proportion value for the terms at issue)*
>
> Does a body of literature use certain words more often than the rest of the culture at large? *(Input: a domain of interest, comparing the proportion value for the terms at issue to proportion values queried from [the Google Ngram Viewer](https://books.google.com/ngrams))*
>
> What are the "interesting" or "unusual" words in this particular dataset, with respect to the rest of the corpus? *(Input: a domain of interest, looking at the TF/IDF values of terms in the entire dataset against the corpus -- large values indicate that a term is "unusual" for the corpus at large but occurs often within the dataset)*
