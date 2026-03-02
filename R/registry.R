# registry.R — Backend and geometry registries
#
# Both registries use a plain environment as a mutable named store.
# Backends and geoms are registered in .onLoad() (see zzz.R).

# ---------------------------------------------------------------------------
# Backend registry
# ---------------------------------------------------------------------------

#' @keywords internal
.backend_registry <- new.env(parent = emptyenv())

#' Register a Rendering Backend
#'
#' Adds a named backend engine to the registry. An engine is a function with
#' the signature `function(spec, geom, ...)` that returns a rendered figure
#' object (a `ggplot` or `highchart`).
#'
#' Third-party packages can call `register_backend()` to add their own
#' backends (e.g. `"plotly"`).
#'
#' @param name Character. Unique backend identifier (e.g. `"ggplot2"`).
#' @param engine A function with signature `function(spec, geom, ...)`.
#'
#' @return `name`, invisibly.
#' @export
#'
#' @examples
#' \dontrun{
#' my_engine <- function(spec, geom, ...) { ... }
#' register_backend("my_backend", my_engine)
#' }
register_backend <- function(name, engine) {
  if (!is.function(engine))
    stop("`engine` must be a function", call. = FALSE)
  .backend_registry[[name]] <- engine
  invisible(name)
}

#' @keywords internal
get_backend <- function(name) {
  .backend_registry[[name]]
}

#' List Registered Backends
#'
#' @return Character vector of registered backend names.
#' @export
#'
#' @examples
#' list_backends()
list_backends <- function() ls(.backend_registry)

# ---------------------------------------------------------------------------
# Geometry registry
# ---------------------------------------------------------------------------

#' @keywords internal
.geom_registry <- new.env(parent = emptyenv())

#' Register a Geometry
#'
#' Adds a named geometry to the registry. A geometry pairs a ggplot2 layer
#' function with a highcharter series function, along with any required
#' arguments beyond x/y.
#'
#' @param name Character. Unique geometry identifier (e.g. `"line"`).
#' @param ggplot_fun Function. Called as `ggplot_fun(spec, ...)` inside the
#'   ggplot2 engine; must return a ggplot2 layer.
#' @param highcharter_fun Function. Called as `highcharter_fun(chart, spec, ...)`
#'   inside the highcharter engine; must return a `highchart` object.
#' @param required_args Character vector. Names of arguments (beyond x/y) that
#'   the geometry requires (e.g. `c("ymin", "ymax")` for `arearange`).
#'
#' @return `name`, invisibly.
#' @export
#'
#' @examples
#' \dontrun{
#' register_geom("violin",
#'   ggplot_fun      = function(spec, ...) ggplot2::geom_violin(...),
#'   highcharter_fun = function(chart, spec, ...) { ... }
#' )
#' }
register_geom <- function(name,
                           ggplot_fun      = NULL,
                           highcharter_fun = NULL,
                           required_args   = character()) {
  .geom_registry[[name]] <- list(
    ggplot_fun      = ggplot_fun,
    highcharter_fun = highcharter_fun,
    required_args   = required_args
  )
  invisible(name)
}

#' @keywords internal
get_geom <- function(name) {
  .geom_registry[[name]]
}

#' List Registered Geometries
#'
#' @return Character vector of registered geometry names.
#' @export
#'
#' @examples
#' list_geoms()
list_geoms <- function() ls(.geom_registry)

# ---------------------------------------------------------------------------
# Shared validation used by make_fig()
# ---------------------------------------------------------------------------

#' @keywords internal
validate_geom_args <- function(geom, args) {
  missing_args <- setdiff(geom$required_args, names(args))
  if (length(missing_args) > 0)
    stop(
      "Missing required argument(s) for this geometry: ",
      paste(missing_args, collapse = ", "),
      call. = FALSE
    )
}
