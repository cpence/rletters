## Display term network

#### This analysis job displays the network of terms associated with a focal word.

The purpose of this job is to evaluate the network of terms that are found near a particular focal word of interest throughout a dataset.  The analysis follows roughly the methodology described in [this paper.](http://noduslabs.com/research/pathways-meaning-circulation-text-network-analysis/)  We begin by producing a stemmed, stopword-free, word-only version of the text.  (At the moment, stemming is only available in English, and hence this algorithm will work **only for English-language texts.**)

We then produce a network by creating connected nodes for (i) each pair of words that includes the focal word, and (ii) each pair of nodes within *each five-word region* containing the focal word.  This emphasizes tight connectivity while also showing some broader structure.

The network graph as drawn adjusts node sizes on the basis of the degree of the node (i.e., the number of nodes connected to that node).  The distance between nodes, as well as the thickness of the lines connecting nodes, are scaled by the number of times that connection appears within the dataset (thicker, shorter connections indicate stronger links).  As mentioned, the network is drawn using stemmed words, holding the mouse over a node on the graph will show the stem as well as all forms of the word found in the dataset.

This job can answer a variety of interesting questions related to the meaning of a particular word within a given dataset:

> What words often appear near a particular focal concept?
>
> Further, what words often appear near *those* words, in this particular context?
