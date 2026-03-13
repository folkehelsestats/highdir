# R/figure-spec.R ── Figure specification objects
#
# Two complementary constructors are provided:
#
#   hd_spec()  — *what* the data means  (x, y, group, n)
#   hd_opts()  — *how* it should look   (title, ylab, ylim, flip, colours, theme)
#
# Keeping them separate means:
#   * The same hd_spec can be rendered with different opts (e.g. EN vs NO
#     titles) without repeating data-mapping code.
#   * hd_opts objects are reusable across multiple specs.
#   * Validation errors are localised to the object they belong to.

# ════════════════════════════════════════════════════════════════════════════
# hd_spec ── data mapping and structure
# ════════════════════════════════════════════════════════════════════════════

#' Create a Figure Data Specification
#'
#' Defines the **data mapping** for a figure — which columns map to x, y,
#' group, and count — independently of any visual presentation choices.
#' Pass the result to [hd_make()] together with an optional [hd_opts()]
#' object.
#'
#' @param data   A `data.frame` containing all referenced columns.
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
hd_spec <- function(data,
                    x,
                    y,
                    group  = NULL,
                    n      = NULL,
                    colour = NULL
                    ) {

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

# ── S3 methods ───────────────────────────────────────────────────────────────

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
