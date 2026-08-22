# R/additional-args.R
#
# Reads geom-registry.yaml (inst/geom-registry.yaml) and builds the
# .geom_registry_defs list that zzz.R uses to register every geometry.
#
# WHY YAML INSTEAD OF HARDCODED R?
# ---------------------------------
# 1. Single source of truth - adding a new geom or argument means editing
#    one human-readable YAML file, not R syntax.
# 2. Language-agnostic - the same YAML can drive documentation generators,
#    Shiny UI builders, and test fixtures without touching R code.
# 3. Easier diffing - YAML diffs are cleaner than R list diffs in code review.
# 4. The object produced is identical to the old hardcoded list, so zzz.R
#    and register_geom() need no changes at all.
#
# HOW IT WORKS
# ------------
# .geom_registry_defs() is called once in zzz.R, right before the
# registration loop.  It reads the YAML, applies post-processing to coerce
# types that YAML cannot express natively (e.g. integer defaults, NULL
# empty-list args), and returns the same nested list structure that zzz.R
# has always expected.
#
# YAML file location: inst/geom-registry.yaml
# Accessed at runtime via system.file() so it works whether the package is
# installed, loaded with devtools::load_all(), or run from source.
#
# ADDING A NEW GEOM
#   1. Add a new top-level key in inst/geom-registry.yaml.
#   2. Write gg_<name> and hc_<name> functions in their own R file.
#   3. That is all - this file and zzz.R need no changes.

# Provides .load_geom_registry() - called once from .onLoad() in zzz.R to
# read inst/geom-registry.yaml and return the .geom_registry_defs list.
#
# WHY NOT ASSIGN AT PARSE TIME?
# ------------------------------
# Assigning .geom_registry_defs directly (with local() or plain <-) during
# file parsing fails for two reasons:
#   1. Helper functions defined later in the file do not exist yet.
#   2. system.file() cannot locate inst/ until the package namespace is
#      registered - which only happens during .onLoad().
#
# The fix: define everything as named functions, call .load_geom_registry()
# from .onLoad(), and assign the result to .geom_registry_defs there.
# zzz.R gains one line; everything else stays the same.


# =============================================================================
# Public loader - called by .onLoad() in zzz.R
# =============================================================================

#' Load and return the geom registry from inst/geom-registry.yaml
#'
#' Returns the same nested list structure that zzz.R's registration loop
#' expects, identical to the old hardcoded `.geom_registry_defs` list.
#' Called once from `.onLoad()` after the package namespace is ready.
#'
#' @keywords internal
.load_geom_registry <- function() {

  # -- Locate YAML -------------------------------------------------------------
  # system.file() works for installed packages, devtools::load_all(), and
  # devtools::check().  It requires the namespace to be registered, which is
  # guaranteed when called from .onLoad().
  yaml_path <- system.file(
    "geom-registry.yaml",
    package = "highdir"
  )

  if (!nzchar(yaml_path))
    stop(
      "highdir: cannot find inst/geom-registry.yaml.\n",
      "Ensure the file exists in inst/ and reinstall or run load_all().",
      call. = FALSE
    )

  # -- Parse -------------------------------------------------------------------
  raw <- yaml::read_yaml(yaml_path)

  # -- Post-process and return -------------------------------------------------
  lapply(raw, .normalise_geom_def)
}


# =============================================================================
# Post-processing helpers
# =============================================================================

#' Normalise one geom definition read from YAML
#'
#' Restores fields that YAML cannot represent natively:
#' - ggplot_fun / highcharter_fun set to NULL (filled later by .onLoad)
#' - skip_base_fig coerced to logical
#' - required_args / optional_args normalised via .normalise_args()
#'
#' @keywords internal
.normalise_geom_def <- function(def) {

  # Function pointers are always NULL here.
  # zzz.R fills them in via .fn() after the namespace is fully loaded.
  def$ggplot_fun      <- NULL
  def$highcharter_fun <- NULL

  # YAML booleans parse as logical already; isTRUE() guards against NULL
  def$skip_base_fig <- isTRUE(def$skip_base_fig)

  # Ensure required_args and optional_args are always named lists
  def$required_args <- .normalise_args(def$required_args)
  def$optional_args <- .normalise_args(def$optional_args)

  def
}


#' Normalise a required_args or optional_args block from YAML
#'
#' YAML type coercions applied per argument:
#' - `null`          -> R `NULL`
#' - whole number    -> `integer` (e.g. `4` -> `4L` for dot_size)
#' - decimal number  -> `double`
#' - `true`/`false`  -> `TRUE`/`FALSE`  (yaml package handles this)
#' - `>` block scalar -> collapsed to a single character string
#' - absent block    -> `list()`  (never NULL or character(0))
#'
#' @keywords internal
.normalise_args <- function(args_block) {

  # NULL or empty mapping {} -> return an empty named list
  if (is.null(args_block) || length(args_block) == 0L)
    return(list())

  lapply(args_block, function(arg) {

    # default: keep NULL as NULL; coerce whole-number doubles to integer
    if (!is.null(arg$default) && is.numeric(arg$default)) {
      if (arg$default == as.integer(arg$default))
        arg$default <- as.integer(arg$default)
    }

    # mode_only: absent key -> NULL (yaml omits it; add it explicitly)
    if (is.null(arg$mode_only))
      arg$mode_only <- NULL

    # desc: YAML '>' scalars sometimes parse as multi-element character
    # vectors in older yaml versions - collapse to a single string
    if (!is.null(arg$desc) && length(arg$desc) > 1L)
      arg$desc <- paste(arg$desc, collapse = " ")

    arg
  })
}
