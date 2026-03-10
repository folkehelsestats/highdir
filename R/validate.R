# R/validate.R ── Centralised pre-render validation
#
# All checks that need to happen before a figure is rendered live here.
# Having one function keeps error messages consistent and easy to update.

#' Validate inputs before rendering a figure
#'
#' Called by [hd_make()] immediately before dispatching to a backend engine.
#' Stops with an informative message if anything is wrong.
#'
#' @param spec        A `hd_spec` object.
#' @param opts        A `hd_opts` object.
#' @param type        Character. Geometry name.
#' @param backend     Character. Backend name.
#' @param extra_args  Named list of additional arguments (for required-arg
#'   check).
#'
#' @return `invisible(NULL)` on success.
#' @keywords internal
validate_fig_inputs <- function(spec, opts, type, backend, extra_args) {

  if (!inherits(spec, "hd_spec"))
    stop("`spec` must be a hd_spec object created by hd_spec().",
         call. = FALSE)

  if (!inherits(opts, "hd_opts"))
    stop("`opts` must be a hd_opts object created by hd_opts().",
         call. = FALSE)

  geom <- .get_geom(type)
  if (is.null(geom))
    stop("Unknown geometry '", type, "'. Available: ",
         paste(sort(list_geoms()), collapse = ", "), call. = FALSE)

  engine <- get_backend(backend)
  if (is.null(engine))
    stop("Unknown backend '", backend, "'. Available: ",
         paste(sort(list_backends()), collapse = ", "), call. = FALSE)

  validate_geom_args(geom, extra_args)

  invisible(NULL)
}
