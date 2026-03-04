# inst/app/global.R ── Loaded by Shiny before ui.R and server.R.
# Everything defined here is visible in both files.

library(highdir)

.has_bslib    <- requireNamespace("bslib",    quietly = TRUE)
.has_webshot2 <- requireNamespace("webshot2", quietly = TRUE)

if (!requireNamespace("rio", quietly = TRUE))
  stop(
    "The 'rio' package is required to run the highdir Shiny app.\n",
    "Install it with:  install.packages('rio')",
    call. = FALSE
  )
