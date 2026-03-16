#
# All register_geom() calls live here so there is one place to see every
# geometry's full contract: required_args (must supply), optional_args
# (have defaults, may omit).
#
# The optional_args field is what eg. geom_args("line") prints for the user.
# Each entry is list(default = <value>, desc = "<short string>").
# The geom function itself applies the default via `geom_params$key %||%
# default` — the registry entry is informational only, not enforced.
#
# Rule of thumb for what goes in optional_args vs required_args:
#   required  — the geom cannot render at all without it (e.g. ymin/ymax)
#   optional  — the geom works fine with a built-in default (e.g. smooth)

#' @keywords internal
.onLoad <- function(libname, pkgname) {

  # ── Built-in colour palettes ───────────────────────────────────────────────
  register_palette("hdir", c(
    "#025169", "#0069E8",
    "#7C145C", "#C68803",
    "#047FA4", "#38A389",
    "#6996CE", "#366558",
    "#BF78DE", "#767676"
  ))

  # hdir2: two-colour palette for binary group comparisons
  ## register_palette("hdir2", c("rgba(49,101,117,1)", "rgba(138,41,77,1)")) ##
  register_palette("hdir2", c("#315975", "#8A294D"))

  # ── Backends ──────────────────────────────────────────────────────────────
  register_backend("ggplot2",     ggplot_engine)
  register_backend("highcharter", highcharter_engine)

  # -- Geometries -------------------------------------------------------------
  # Geom optional args need to be defined here. They will be used in two different
  # places:
  # 1 - geom_args()
  # 2 - app output$ui_geom_opts() or geom_intpu_r object in Shiny server
  # --------------------------------------------------------------------------
  # .geom_registry_defs is defined in R/additional_args.R.
  # The gg_* and hc_* function objects are looked up here by name so that
  # the plain list in additional_args.R does not need to reference them
  # (function objects are not available at list-parse time in that file).
  .fn <- function(geom_name, suffix) {
    fn_name <- paste0(suffix, "_", geom_name)
    if (exists(fn_name, mode = "function", envir = parent.env(environment()),
               inherits = TRUE))
      get(fn_name, mode = "function", envir = parent.env(environment()),
          inherits = TRUE)
    else
      NULL
  }

  for (g in names(.geom_registry_defs)) {
    def <- .geom_registry_defs[[g]]
    register_geom(
      name            = g,
      ggplot_fun      = .fn(g, "gg"),
      highcharter_fun = .fn(g, "hc"),
      required_args   = def$required_args %||% character(),
      optional_args   = def$optional_args %||% list(),
      is_map_geom     = isTRUE(def$is_map_geom)
    )
  }

  # ── Option defaults ────────────────────────────────────────────────────────
  op     <- options()
  to_set <- .hd_defaults[!names(.hd_defaults) %in% names(op)]
  if (length(to_set)) options(to_set)

  invisible()
}
