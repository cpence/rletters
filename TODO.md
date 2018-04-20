*   Check that everywhere that has required: true has .invalid-feedback with validation_errors_for
*   Float all submit buttons to the right of their forms
*   Center all form div's within their space if we're constricting them on large screens
*   Standardize capitalization and wahtnot on all of our validation errors, they're a mess
*   Standardize e-mail vs email


*   GDPR compliance todo:
    -   [backend done, need frontend] User data export to ZIP in machine-readable formats
    -   Make sure that deleting a user account will cascade to deleting all datasets, queries, tasks, and files for that user
    -   Remove Google Analytics support
    -   Ensure that profile editing can edit all fields about the user
    -   On sign-up, ask if users are under 16; either do not allow them to register or ask a parent for permission
    -   Consider implementing papertrail for logging all changes to user data and where they came from

*   New admin panel:
    -   Need to be able to edit:
        +   Categories
        +   Stop lists
        +   CSL styles
        +   Custom pages
        +   Custom images
