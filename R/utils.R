# R/utils.R ── Internal helpers (not exported)
#
# All small utilities used across the package live here so there is a single
# place to look for them.  Nothing in this file is exported.

# ── NULL coalescing ──────────────────────────────────────────────────────────

#' @keywords internal
`%||%` <- function(a, b) if (is.null(a)) b else a

# ── Type predicates ──────────────────────────────────────────────────────────

#' @keywords internal
is_highchart <- function(x) inherits(x, "highchart")

#' @keywords internal
is_ggplot <- function(x) inherits(x, c("gg", "ggplot"))

# ── Validation helpers ───────────────────────────────────────────────────────

#' Stop with a tidy message when columns are absent from a data frame
#' @keywords internal
check_columns <- function(data, cols, arg_name = "data") {
  cols    <- cols[!is.null(cols) & !is.na(cols)]
  missing <- setdiff(cols, names(data))
  if (length(missing) > 0)
    stop("Column(s) not found in `", arg_name, "`: ",
         paste(missing, collapse = ", "), call. = FALSE)
  invisible(NULL)
}

#' Validate the ylim argument
#' @keywords internal
check_ylim <- function(ylim) {
  if (is.null(ylim)) return(invisible(NULL))
  if (!is.numeric(ylim) || length(ylim) != 2)
    stop("`ylim` must be a numeric vector of length 2, e.g. c(0, 100)",
         call. = FALSE)
  if (ylim[1] >= ylim[2])
    stop("`ylim[1]` must be less than `ylim[2]`", call. = FALSE)
  invisible(NULL)
}

# --- Line-symbol helpers ----

#' Valid Highcharts marker symbol names
#' @keywords internal
.hc_symbols <- c("circle", "square", "diamond", "triangle", "triangle-down")

#' Resolve and validate line symbols for n groups
#'
#' @param n   Integer. Number of groups.
#' @param symbols Character vector or `NULL` supplied by the user.
#' @return Character vector of length `n`.
#' @keywords internal
resolve_symbols <- function(n, symbols = NULL) {
  if (is.null(symbols))
    return(rep(.hc_symbols, length.out = n))

  invalid <- setdiff(symbols, .hc_symbols)
  if (length(invalid) > 0) {
    warning("Invalid marker symbol(s): ", paste(invalid, collapse = ", "),
            ". Valid: ", paste(.hc_symbols, collapse = ", "),
            ". Using defaults.", call. = FALSE)
    return(rep(.hc_symbols, length.out = n))
  }
  if (length(symbols) != n)
    warning("Number of symbols (", length(symbols), ") != groups (", n,
            "). Recycling.", call. = FALSE)
  rep(symbols, length.out = n)
}

## ----- Modules dependency -----------
#' Version-safe hc_add_dependency wrapper
#'
#' highcharter 0.9.4 takes the path as a positional argument.
#' Older versions used name = . This wrapper handles both.
#' @keywords internal
.hd_add_dep <- function(chart, path) {
  tryCatch(
    highcharter::hc_add_dependency(chart, path),
    error = function(e)
      highcharter::hc_add_dependency(chart, name = path)
  )
}

## ---- Axis labelling -----------
#' Resolve an axis label from opts and spec
#'
#' Three-way logic:
#'   NULL   → hide the axis label entirely
#'   " "    → use the column name from spec as the fallback
#'   string → use the string as-is
#'
#' @param opts_label The value from hd_opts()$ylab or $xlab.
#' @param spec_col   The column name from hd_spec()$y or $x.
#' @return Character string or NULL.
#' @keywords internal
.resolve_axis_label <- function(opts_label, spec_col) {

  if (is.null(opts_label))
    return(NULL)          # explicit NULL → hide

  if (identical(opts_label, " "))
    return(spec_col)      # sentinel → use column name

  opts_label              # any other string → use as-is
}
