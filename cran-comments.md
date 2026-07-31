## R CMD check results

0 errors | 0 warnings | 0 notes

* This is a major update (version 0.6.0).
* Several bugs have been fixed and parts of the API have been refined.
* Function arguments have been renamed and clarified to improve consistency, readability, and ease of use.
* Backward compatibility has been maintained where possible through deprecation warnings for superseded arguments.
* The package title and description have been updated to better describe the package scope.

## Resubmission
* Package names and technical terms (`highcharter`, `ggplot2`, and `JavaScript`) have been quoted in DESCRIPTION to avoid false-positive spelling notes.
* URLs in README.md and NEWS.md that previously returned HTTP 301 redirects have been updated to use their final destination URLs directly.
* Trailings slashes were added to the URLs
* The previously reported top-level file NOTE has been addressed by removing `README.html` from the package source.
* The term "backends" in the DESCRIPTION file has been replaced with "packages" to avoid a false-positive spelling note reported during CRAN checks.

Thank you for your review and helpful suggestions.
