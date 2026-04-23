
# -- Package-level option defaults ---------------------------------------------

# These are the default values for options used in the package. They will be set
# as falls back if the user has not set them in their R session. See .onLoad()
# in R/zzz.R for where these are set.

#' @keywords internal
.hd_defaults <- list(
  highdir.hc_theme   = "default",
  highdir.gg_theme   = "classic",
  highdir.colors     = NULL,
  highdir.font       = NULL,
  highdir.js_plugins = character(0),
  highdir.backend    = "highcharter"   # default engine for hd()
)
