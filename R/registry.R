#
# Both registries use a plain environment as a mutable named store.
# Backends and geoms are registered in .onLoad() (zzz.R).

# ── Backend registry ----------------------------------------------------------

#' @keywords internal
.backend_registry <- new.env(parent = emptyenv())

#' Register a Rendering Backend
#' @param name   Character. Unique backend identifier (e.g. `"ggplot2"`).
#' @param engine Function.
#' @return `name`, invisibly.
#' @export
register_backend <- function(name, engine) {
  if (!is.function(engine))
    stop("`engine` must be a function.", call. = FALSE)
  .backend_registry[[name]] <- engine
  invisible(name)
}

#' @keywords internal
get_backend <- function(name) .backend_registry[[name]]

#' List Registered Backends
#' @return Character vector of registered backend names.
#' @export
list_backends <- function() sort(ls(.backend_registry))

# ── Geometry registry ---------------------------------------------------------

#' @keywords internal
.geom_registry <- new.env(parent = emptyenv())

#' Register a Geometry
#'
#' Adds a geometry to the registry.  The `optional_args` field is the key
#' mechanism for user discoverability: it is what `geom_args()` prints, what
#' the Shiny app reads to build dynamic UI, and what automated documentation
#' can harvest without parsing source code.
#'
#' Structure of `optional_args`:
#' A named list where each element is itself a list with two fields:
#'   `default` — the value used when the arg is not supplied (may be `NULL`)
#'   `desc`    — a short human-readable description (shown by `geom_args()`)
#'
#' Example:
#' ```r
#' optional_args = list(
#'   smooth   = list(default = TRUE,  desc = "Spline smoothing (logical)"),
#'   dot_size = list(default = 4,     desc = "Marker radius in px (numeric)")
#' )
#' ```
#'
#' @param name            Character. Unique geometry identifier.
#' @param ggplot_fun      Function or `NULL`.
#' @param highcharter_fun Function or `NULL`.
#' @param required_args   Named list of `list(default, desc)`. Args that MUST be supplied via
#'   `...` in `hd_make()`. Validation fails if any are missing.
#' @param optional_args   Named list of `list(default, desc)`. Args that MAY
#'   be supplied and have a sensible default when omitted.  These are purely
#'   informational from the registry's perspective — the geom function applies
#'   the defaults itself via `geom_params$key %||% default`.
#' @param is_map_geom     Logical. Bypasses `base_fig()` in both engines.
#'
#' @return `name`, invisibly.
#' @export
register_geom <- function(name,
                          ggplot_fun      = NULL,
                          highcharter_fun = NULL,
                          required_args   = list(),
                          optional_args   = list(),
                          is_map_geom     = FALSE) {

  # optional_args must be a named list of list(default, desc) entries.
  # Validate structure so mis-registrations fail loudly at load time rather
  # than silently producing wrong output for users.
  if (length(optional_args) > 0) {
    if (is.null(names(optional_args)) || any(!nzchar(names(optional_args))))
      stop("register_geom(): `optional_args` must be a fully named list.",
           call. = FALSE)
    bad <- vapply(optional_args, function(x)
      !is.list(x) || !all(c("default", "desc") %in% names(x)),
      logical(1))
    if (any(bad))
      stop("register_geom(): each entry in `optional_args` must be ",
           "list(default = ..., desc = ...).  Bad entries: ",
           paste(names(optional_args)[bad], collapse = ", "),
           call. = FALSE)
  }

  .geom_registry[[name]] <- list(
    name            = name,             # stored so geom fns can self-identify
    ggplot_fun      = ggplot_fun,
    highcharter_fun = highcharter_fun,
    required_args   = required_args,
    optional_args   = optional_args,    # NEW: user-discoverable optional args
    is_map_geom     = is_map_geom
  )
  invisible(name)
}

#' @keywords internal
.get_geom <- function(name) .geom_registry[[name]]

#' List Registered Geometries
#' @return Character vector of registered geometry names.
#' @export
list_geoms <- function() sort(ls(.geom_registry))

# ── geom_args(): user-facing discoverability helper ---------------------------

#' Show Arguments for a Geometry
#'
#' Prints the required and optional `...` arguments accepted by a geometry
#' when used with [hd_make()].  This is the primary discoverability tool
#' for geometry-specific arguments that do not appear in `hd_make()`'s
#' signature.
#'
#' @section Why this exists:
#' `hd_make()` uses `...` for all geometry-specific arguments so its own
#' signature stays clean regardless of how many geometries are registered.
#' The trade-off is that users cannot see available args from `hd_make()`
#' alone.  `geom_args()` solves that: it reads the `required_args` and
#' `optional_args` fields registered for each geometry and presents them
#' in a readable table.
#'
#' @param type Character.  Geometry name, e.g. `"line"`, `"ranked_bar"`.
#'   If `NULL` (default), prints a summary for every registered geometry.
#'
#' @return A data frame of argument metadata, invisibly.  The primary purpose
#'   is the side-effect of printing.
#'
#' @examples
#' geom_args("line")
#' geom_args("ranked_bar")
#' geom_args("arearange")
#' geom_args()           # all registered geometries
#'
#' @export
geom_args <- function(type = NULL) {

  # If no type given, recurse over every registered geometry
  if (is.null(type)) {
    nms <- list_geoms()
    for (nm in nms) geom_args(nm)
    return(invisible(NULL))
  }

  geom <- .get_geom(type)
  if (is.null(geom))
    stop("Unknown geometry '", type, "'. See list_geoms().", call. = FALSE)

  # ── Build a data frame with one row per argument ----------------------------
  rows <- list()

  # Required args: have a default, may be omitted
  for (arg in names(geom$required_args)) {
    entry   <- geom$required_args[[arg]]
    default <- if (is.null(entry$default)) "NULL"
               else as.character(entry$default)
    rows[[length(rows) + 1L]] <- data.frame(
      argument = arg,
      kind     = "required",
      default  = default,
      desc     = entry$desc,
      stringsAsFactors = FALSE
    )
  }

  # Optional args: have a default, may be omitted
  for (arg in names(geom$optional_args)) {
    entry   <- geom$optional_args[[arg]]
    default <- if (is.null(entry$default)) "NULL"
               else as.character(entry$default)
    rows[[length(rows) + 1L]] <- data.frame(
      argument = arg,
      kind     = "optional",
      default  = default,
      desc     = entry$desc,
      stringsAsFactors = FALSE
    )
  }

  if (length(rows) == 0L) {
    message("geom '", type, "' has no extra arguments.")
    return(invisible(data.frame()))
  }

  out <- do.call(rbind, rows)

  # ── Print a readable table --------------------------------------------------
  cat(sprintf("\nArguments for hd_make(..., type = \"%s\", ...):\n\n", type))

  # Compute column widths for alignment
  w_arg  <- max(nchar("argument"), nchar(out$argument))
  w_kind <- max(nchar("kind"),     nchar(out$kind))
  w_def  <- max(nchar("default"),  nchar(out$default))

  fmt <- paste0("  %-", w_arg, "s  %-", w_kind, "s  %-", w_def, "s  %s\n")
  cat(sprintf(fmt, "argument", "kind", "default", "description"))
  cat(sprintf(fmt,
              strrep("-", w_arg),
              strrep("-", w_kind),
              strrep("-", w_def),
              strrep("-", 30)))

  for (i in seq_len(nrow(out))) {
    cat(sprintf(fmt, out$argument[i], out$kind[i],
                out$default[i], out$desc[i]))
  }
  cat("\n")

  invisible(out)
}

