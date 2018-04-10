*   Check that everywhere that has required: true has .invalid-feedback with validation_errors_for
*   Float all submit buttons to the right of their forms
*   Center all form div's within their space if we're constricting them on large screens
*   Standardize capitalization and wahtnot on all of our validation errors, they're a mess
*   Standardize e-mail vs email


*   Administration console currently lets us:
    -   see recent tasks, users, datasets
    -   look at job workers
    -   inspect some backend information and environment variables
    -   edit:
        +   users and library links
        +   administrator accounts themselves
        +   datasets, queries, tasks
        +   categories
        +   stop lists
        +   CSL styles
        +   custom page content
        +   custom image assets


*   Replacements:
    -   Need a rake task that will print details on currently running job workers, in concert with the work on timeout-based worker watcher support that's about to hit.
    -   Need to be able to edit:
        +   Categories
        +   Stop lists
        +   CSL styles
    -   Could make stop list edits and CSL style edits a user-account feature. That is, you get the canned set from RL and if you want to add more, you do that per-user.
        +   Categories, however, look to be an inescapably site-local configuration problem. Is there *any* way to do these without a browser-based administration interface? (Do we want to keep them?!)
    -   To investigate: replacing custom page content and assets with filesystem content?
