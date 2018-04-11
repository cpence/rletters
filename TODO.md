*   Check that everywhere that has required: true has .invalid-feedback with validation_errors_for
*   Float all submit buttons to the right of their forms
*   Center all form div's within their space if we're constricting them on large screens
*   Standardize capitalization and wahtnot on all of our validation errors, they're a mess
*   Standardize e-mail vs email


*   New admin panel:
    -   Need a rake task that will print details on currently running job workers, in concert with the work on timeout-based worker watcher support that's about to hit.
    -   Dupe same thing in admin view
    -   Need to be able to edit:
        +   Categories
        +   Stop lists
        +   CSL styles
        +   Custom pages
        +   Custom images
