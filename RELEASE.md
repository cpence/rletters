# Release Instructions

1.  Make sure your local commit is up to date:

    ```shell_session
    $ git status
    On branch master
    Your branch is up to date with 'origin/master'.

    nothing to commit, working tree clean
    $ git push
    Everything up-to-date
    $ git pull
    Already up to date.
    ```

2.  Make sure the tests all pass:
    
    ```shell_session
    $ bin/rails test
    $ bin/rails test:system
    ```

3.  Pull the latest translation files from Transifex:

    ```shell_session
    $ bin/rails rletters:locales:pull
    $ git status
    $ git commit -m 'Pull locales from Transifex. [ci:skip]'
    $ git push
    ```

4.  Update the README and ChangeLog. The version number may appear multiple times, be sure to catch them all. Make sure to write the release date in the ChangeLog header.

    ```shell_session
    $ # edit files
    $ git commit -m 'Update README and ChangeLog for release. [ci:skip]'
    $ git push
    ```

5.  Create a new release tag and push it upstream:

    ```shell_session
    $ git tag -am 'vX.Y' vX.Y
    $ git push --tags
    ```

6.  Visit GitHub Releases. Click "Draft a new release." Select the new tag you just created from the pull-down menu. Under "Release title," repeat the tag name, "vX.Y". If the changeset for this release is small enough that you can summarize it in a bulleted list, do that in the description, otherwise simply write "See ChangeLog for details.".
