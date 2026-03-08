# inst/app/global.R
# ── Loaded by Shiny before ui.R and server.R ──────────────────────────────────
#
# Everything defined here is visible in both ui.R and server.R.
#
# MODULE SOURCING:
# Modules are sourced in server.R (not here) because they need Shiny's session
# scoping to work correctly.  global.R is the right place for package loading
# and package-level checks only.

library(highdir)

# local = TRUE keeps each module's internal helpers out of the global env.
source("modules/mod_data.R",    local = FALSE)
source("modules/mod_opts.R",    local = FALSE)
source("modules/mod_figure.R",  local = FALSE)

# Optional packages — checked once at startup, not on every request
.has_webshot2 <- requireNamespace("webshot2", quietly = TRUE)

if (!requireNamespace("rio", quietly = TRUE))
  stop(
    "The 'rio' package is required to run the highdir Shiny app.\n",
    "Install it with:  install.packages('rio')",
    call. = FALSE
  )

if (!requireNamespace("DT", quietly = TRUE))
  stop(
    "The 'DT' package is required to run the highdir Shiny app.\n",
    "Install it with:  install.packages('DT')",
    call. = FALSE
  )
