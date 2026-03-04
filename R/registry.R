# R/registry.R ── Backend and geometry registries
#
# Both registries use a plain environment as a mutable named store.
# Backends and geoms are registered in .onLoad() (zzz.R).
# Third-party packages can extend both registries at their own .onLoad().

# ── Backend registry ─────────────────────────────────────────────────────────

#' @keywords internal
.backend_registry <- new.env(parent = emptyenv())

#' Register a Rendering Backend
#'
#' Adds a named engine function to the backend registry.  The engine receives
#' `(spec, geom, opts, geom_params, use_js, filename)` and must return a
#' rendered figure object (`ggplot` or `highchart`).
#'
#' Third-party packages call this in their own `.onLoad()` to add backends
#' such as `"plotly"` or `"echarts4r"`.
#'
#' @param name   Character. Unique backend identifier (e.g. `"ggplot2"`).
#' @param engine Function with signature
#'   `function(spec, geom, opts, geom_params, use_js, filename, ...)`.
#'
#' @return `name`, invisibly.
#' @export
#'
#' @examples
#' \dontrun{
#' my_engine <- function(spec, geom, opts, geom_params, use_js, filename, ...) {
#'   # return a rendered figure
#' }
#' register_backend("my_backend", my_engine)
#' list_backends()
#' }
register_backend <- function(name, engine) {
  if (!is.function(engine))
    stop("`engine` must be a function.", call. = FALSE)
  .backend_registry[[name]] <- engine
  invisible(name)
}

#' @keywords internal
get_backend <- function(name) .backend_registry[[name]]

#' List Registered Backends
#'
#' @return Character vector of registered backend names.
#' @export
#' @examples
#' list_backends()
list_backends <- function() sort(ls(.backend_registry))

# ── Geometry registry ────────────────────────────────────────────────────────

#' @keywords internal
.geom_registry <- new.env(parent = emptyenv())

#' Register a Geometry
#'
#' Adds a named geometry to the geom registry.  A geometry pairs a ggplot2
#' layer function with a highcharter series function.
#'
#' The geom functions receive `(spec, opts, geom_params, ...)` for ggplot2 and
#' `(chart, spec, opts, geom_params, use_js, ...)` for highcharter.
#' `geom_params` is a named list containing all geom-specific arguments
#' (e.g. `smooth`, `dot_size`, `ymin`, `ymax`).
#'
#' @param name            Character. Unique geometry identifier.
#' @param ggplot_fun      Function or `NULL`.  ggplot2 layer builder.
#' @param highcharter_fun Function or `NULL`.  highcharter series builder.
#' @param required_args   Character vector.  Names of required `geom_params`
#'   entries beyond x/y (e.g. `c("ymin", "ymax")` for `"arearange"`).
#'
#' @return `name`, invisibly.
#' @export
#'
#' @examples
#' \dontrun{
#' register_geom(
#'   "violin",
#'   ggplot_fun      = function(spec, opts, geom_params, ...) ggplot2::geom_violin(),
#'   highcharter_fun = NULL,   # highcharter has no violin
#'   required_args   = character()
#' )
#' }
register_geom <- function(name,
                          ggplot_fun      = NULL,
                          highcharter_fun = NULL,
                          required_args   = character(),
                          is_map_geom     = FALSE) {
  .geom_registry[[name]] <- list(
    ggplot_fun      = ggplot_fun,
    highcharter_fun = highcharter_fun,
    required_args   = required_args,
    is_map_geom     = is_map_geom
  )
  invisible(name)
}

#' @keywords internal
get_geom <- function(name) .geom_registry[[name]]

#' List Registered Geometries
#'
#' @return Character vector of registered geometry names.
#' @export
#' @examples
#' list_geoms()
list_geoms <- function() sort(ls(.geom_registry))

# ── Shared validation ────────────────────────────────────────────────────────

#' @keywords internal
validate_geom_args <- function(geom, extra_args) {
  missing_args <- setdiff(geom$required_args, names(extra_args))
  if (length(missing_args) > 0)
    stop("Missing required argument(s) for this geometry: ",
         paste(missing_args, collapse = ", "), call. = FALSE)
}
