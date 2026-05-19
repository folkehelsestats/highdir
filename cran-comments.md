## R CMD check results

0 errors | 0 warnings | 0 notes

* This is a new release (version 0.5.0).

## Resubmission

The following issues raised during the previous review have been addressed:

* Fixed URL formatting in Markdown.
* Replaced unsupported Unicode character (U+2500) with LaTeX-compatible alternatives.
* Updated Title to use straight single quotes for package names.
* Ensured that all package names, software names, and API names are written in single quotes in the Description field.
* Added `\value{}` sections to the documentation of exported functions and clarified the structure and meaning of returned objects (e.g., in `hd_geom_scatter.Rd`).
* Replaced inappropriate use of `\dontrun{}` with `\donttest{}` or `if (interactive()) {}` in examples, where applicable.

Thank you for your review and helpful suggestions.
