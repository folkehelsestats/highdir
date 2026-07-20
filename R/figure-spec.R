# Figure specification objects
#
# Two complementary constructors are provided:
#
#   hd_spec()  - *what* the data means  (x, y, group, n)
#   hd_opts()  - *how* it should look   (title, ylab, ylim, flip, colours, theme)
#
# Keeping them separate means:
#   * The same hd_spec can be rendered with different opts (e.g. EN vs NO
#     titles) without repeating data-mapping code.
#   * hd_opts objects are reusable across multiple specs.
#   * Validation errors are localised to the object they belong to.

# ------------------------------------------------------------------------------
# hd_spec  data mapping and structure
# ------------------------------------------------------------------------------
# 
#' Create a Figure Data Specification
#'
#' Defines the **data mapping** for a figure - which columns map to x, y,
#' group, and count - independently of any visual presentation choices.
#' Pass the result to [hd_make()] together with an optional [hd_opts()]
#' object.
#'
#' @param data   A `data.frame` containing all referenced columns. Default is `NULL`,
#'   which creates an empty data.frame.  The original data source is recorded
#'   in the `"src_data"` attribute for printing and debugging purposes.
#' @param x      Character. Column name for the x-axis variable.
#' @param y      Character. Column name for the y-axis variable (typically
#'   a percentage or count).
#' @param group  Character or `NULL`. Column used to split data into multiple
#'   series.
#' @param n      Character or `NULL`. Column of raw counts shown in
#'   highcharter tooltips alongside the y value.  Ignored by ggplot2.
#' @param colour Character or `NULL`. ggplot2 colour aesthetic column.
#'   Defaults to `group` when `NULL` and `group` is set.
#'
#' @return An S3 object of class `"hd_spec"`.
#'
#' @seealso [hd_opts()], [hd_make()]
#'
#' @examples
#' df <- data.frame(
#'   age = rep(c("18-24", "25-34", "35-44", "45-54"), each = 2),
#'   sex = rep(c("Male", "Female"), 4),
#'   pct = c(42, 38, 55, 61, 48, 52, 60, 57),
#'   n   = c(120, 115, 200, 210, 180, 175, 160, 155)
#' )
#'
#' spec <- hd_spec(df, x = "age", y = "pct", group = "sex", n = "n")
#' spec
#'
#' @export
hd_spec <- function(data   = NULL,
                    x,
                    y,
                    group  = NULL,
                    n      = NULL,
                    colour = NULL
                    ) {

  if (is.null(data))
    data <- data.frame()
  
  data.table::setattr(data, "src_data", deparse1(substitute(data)))

  if (!is.data.frame(data))
    stop("`data` must be a data.frame.", call. = FALSE)

  check_columns(data, c(x, y, group, n, colour))

  structure(
    list(
      data   = as.data.frame(data),   # strip tibble/data.table subclasses
      x      = x,
      y      = y,
      group  = group,
      n      = n,
      colour = colour
    ),
    class = "hd_spec"
  )
}

# -- S3 methods ----------------------------------------------------------------

#' @export
print.hd_spec <- function(x, ...) {
  cat("<hd_spec>\n")
  cat("  data   :", get_src_data(x$data),  "\n")
  cat("  x      :", x$x,    "\n")
  cat("  y      :", x$y,    "\n")
  if (!is.null(x$group))  cat("  group  :", x$group,  "\n")
  if (!is.null(x$n))      cat("  n      :", x$n,      "\n")
  if (!is.null(x$colour)) cat("  colour :", x$colour, "\n")
  cat("  rows   :", nrow(x$data), "\n")
  invisible(x)
}

#' @export
as.list.hd_spec <- function(x, ...) {
  out      <- unclass(x)
  out$data <- sprintf("<data.frame [%d x %d]>", nrow(x$data), ncol(x$data))
  out
}


#' @keywords internal
get_src_data <- function(obj) {
  nm <- attr(obj, "src_data")
  return(if (is.null(nm)) "<?>" else nm)
}


# ------------------------------------------------------------------------------
# hd_spec_venn  venn / euler data specification
# ------------------------------------------------------------------------------
#
# hd_spec_venn() is the declarative-API equivalent of calling hd_spec() for
# geoms that use x/y columns.  For venn/euler diagrams the "data" is a list
# of set entries rather than a flat data frame, so the standard hd_spec()
# constructor cannot be used directly (it requires x and y column names and
# validates them against the data frame).
#
# hd_spec_venn() wraps the set list in a minimal hd_spec object:
#
#   spec$data  -- a one-row data.frame with a single column ".venn_sets"
#                 whose value is list(sets).  This is the conventional
#                 storage pattern for non-rectangular data inside hd_spec.
#   spec$x     -- ".venn_sets"  (sentinel; signals to engines that this is
#                 a venn spec and base_fig() must be skipped)
#   spec$y     -- ".value"      (sentinel; unused but satisfies hd_spec structure)
#   spec$group -- NULL
#   spec$n     -- NULL
#
# When passed to hd_make() the sets are supplied again via ...:
#
#   hd_make(spec_v, "venn", opts, sets = spec_v$data[[".venn_sets"]][[1]])
#
# hd_venn_sets_from_spec() is a convenience extractor that retrieves the
# set list back from a spec created by hd_spec_venn().
#

#' Create a Venn / Euler Figure Specification
#'
#' Declarative-API equivalent of [hd_spec()] for venn and euler diagrams.
#' Wraps a pre-built set list inside an `hd_spec` object so it can be passed
#' to [hd_make()] using the same `spec / opts / hd_make()` pattern as every
#' other highdir geometry.
#'
#' @section Usage with hd_make():
#' ```r
#' sets <- list(
#'   hd_venn_set("A", "Oslo",   120),
#'   hd_venn_set("B", "Bergen",  95),
#'   hd_venn_intersect(c("A","B"), 40)
#' )
#'
#' spec_v <- hd_spec_venn(sets)
#' opts_v <- hd_opts(title = "City overlap")
#'
#' # Declarative API - identical pattern to every other geom
#' hd_make(spec_v, "venn", opts_v)                       # highcharter
#' hd_make(spec_v, "venn", opts_v, backend = "ggplot2")  # ggplot2
#' ```
#'
#' @section Compared to the composable API:
#' Both approaches produce identical output.  Use whichever fits your workflow:
#' ```r
#' # Declarative (hd_spec / hd_opts / hd_make)
#' hd_make(hd_spec_venn(sets), "venn", hd_opts(title = "City overlap"))
#'
#' # Composable (hd / + / hd_geom_venn)
#' hd(backend = "highcharter") +
#'   hd_geom_venn(sets = sets) +
#'   hd_opts(title = "City overlap")
#' ```
#'
#' @param sets  A non-empty list of set entries built with [hd_venn_set()]
#'   and [hd_venn_intersect()], or raw named lists following the format:
#'   `list(sets = list("A"), name = "Label", value = 5)`.
#'
#' @return An S3 object of class `c("hd_spec_venn", "hd_spec")`.
#'
#' @seealso [hd_venn_set()], [hd_venn_intersect()], [hd_venn_sets_from_spec()],
#'   [hd_make()], [hd_opts()]
#'
#' @examples
#' \donttest{
#' sets <- list(
#'   hd_venn_set("A", "Oslo",   value = 120),
#'   hd_venn_set("B", "Bergen", value = 95),
#'   hd_venn_intersect(c("A", "B"), value = 40)
#' )
#' spec_v <- hd_spec_venn(sets)
#' opts_v <- hd_opts(title = "City overlap")
#'
#' hd_make(spec_v, "venn", opts_v)
#' hd_make(spec_v, "venn", opts_v, backend = "ggplot2")
#' hd_make(hd_spec_venn(sets), "venn", hd_opts(title = "City overlap"))
#' }
#'
#' @export
hd_spec_venn <- function(sets) {

  # Reuse the same validator as hd_geom_venn
  .validate_venn_sets(sets, call_name = "hd_spec_venn")

  # Wrap the set list in a one-row data.frame so it travels in the same
  # $data slot as every other hd_spec, without requiring x/y columns.
  # I(list(sets)) uses AsIs to prevent data.frame() from unlisting.
  wrapper_df <- data.frame(.venn_sets = I(list(sets)),
                           .value     = NA_real_)

  structure(
    list(
      data   = wrapper_df,
      x      = ".venn_sets",   # sentinel - engines check for this
      y      = ".value",       # sentinel - unused, satisfies hd_spec contract
      group  = NULL,
      n      = NULL,
      colour = NULL
    ),
    class = c("hd_spec_venn", "hd_spec")
  )
}


#' Extract the Set List from an hd_spec_venn Object
#'
#' Convenience extractor to retrieve the set list stored inside a spec
#' created by [hd_spec_venn()].  Useful when you want to inspect or extend
#' the set list before passing to [hd_make()].
#'
#' @param spec An `hd_spec_venn` object.
#'
#' @return The set list (same object that was passed to [hd_spec_venn()]).
#'
#' @examples
#' sets   <- list(hd_venn_set("A", "Oslo", 120))
#' spec_v <- hd_spec_venn(sets)
#' hd_venn_sets_from_spec(spec_v)   # returns the original sets list
#'
#' @export
hd_venn_sets_from_spec <- function(spec) {
  if (!inherits(spec, "hd_spec_venn"))
    stop("hd_venn_sets_from_spec(): `spec` must be an hd_spec_venn object.",
         call. = FALSE)
  spec$data[[".venn_sets"]][[1L]]
}


#' @export
print.hd_spec_venn <- function(x, ...) {
  sets <- hd_venn_sets_from_spec(x)
  cat("<hd_spec_venn>\n")
  cat("  sets   :", length(sets), "entries\n")
  single_sets <- Filter(function(e) length(e$sets) == 1L, sets)
  inter_sets  <- Filter(function(e) length(e$sets) >  1L, sets)
  if (length(single_sets))
    cat("  groups :", paste(vapply(single_sets, function(e)
      paste0(e$sets[[1L]], " (", e$value, ")"), character(1)),
      collapse = ", "), "\n")
  if (length(inter_sets))
    cat("  inters :", length(inter_sets), "intersection(s)\n")
  invisible(x)
}
