# Developer checklist

This list guides you through the steps you need to take to make the smallest change to a smart-answer, for example changing the text on a landing page.

1. Make the change to the code/template
2. Commit the change
3. Run the [regression tests](regression-tests)
4. Commit changes to the [test artefacts](regression-tests.md#artefacts)
5. Re-run the regression tests
6. Regenerate the [checksums](regression-tests.md#checksums)
7. (Optional) Re-run the regression tests
8. Commit the changes to the checksums
9. Create a pull request
10. (Optional) Deploy an app to [Heroku](factcheck.md#deploying-to-heroku) for factcheck
  1. Add a "Waiting for factcheck" label to the pull request
