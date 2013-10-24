## Differentiate two datasets

#### This analysis job can tell you what makes two sets of articles different from one another, using the "Zeta" algorithm.

The algorithm implemented here is Zeta, originally described [by John F. Burrows in 2007](10.1093/llc/fqi067) and expanded [by Hugh Craig,](https://en.wikipedia.org/w/index.php?title=Special%3ABookSources&isbn=9780521516235) as implemented by [David L. Hoover.](https://files.nyu.edu/dh3/public/UsingtheCraigZetaSpreadsheet.html)  This algorithm takes two datasets as input (call them A and B), and returns two lists of words.  Each list of words is a set of words -- which are neither particularly common nor exceedingly rare -- that are likely to mark a text out as belonging to set A or set B respectively.  That is, if "Germany" is a Zeta word for set A, then the appearance of "Germany" in a text makes it much more likely to belong to set A than to set B.

This algorithm can be used to answer the following kinds of questions:

> What terms are commonly used within one set, but rarely used outside of it? *(Input: two datsets, one set of interest and one set containing the rest of the corpus)*
> 
> What terms make one strand of discourse different from another? *(Input: two datsets, one each from each strand of discourse)*
>
> What concepts have entered or left a discipline over time? *(Input: one dataset of earlier works, one dataset of later works)*
