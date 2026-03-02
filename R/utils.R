# utils.R — Internal helpers
#
# None of these are exported. They are used across the package internally.

# ---------------------------------------------------------------------------
# NULL coalescing
# ---------------------------------------------------------------------------

#' @keywords internal
`%||%` <- function(a, b) if (is.null(a)) b else a

# ---------------------------------------------------------------------------
# Type predicates
# ---------------------------------------------------------------------------

#' @keywords internal
is_highchart <- function(x) inherits(x, "highchart")

#' @keywords internal
is_ggplot <- function(x) inherits(x, c("gg", "ggplot"))

# ---------------------------------------------------------------------------
# Colour palette helpers
# ---------------------------------------------------------------------------

#' Helsedirektoratet 10-colour palette
#'
#' @keywords internal
.hdir_colors <- c(
  "#025169", "#0069E8",
  "#7C145C", "#047FA4",
  "#C68803", "#38A389",
  "#6996CE", "#366558",
  "#BF78DE", "#767676"
)

#' Resolve colour vector for n groups
#'
#' Returns a character vector of `n` colours using the hdir palette for 1–7
#' groups, a two-colour teal/purple pair for exactly 2 groups, and viridis
#' for 8+ groups.
#'
#' @param n Integer. Number of groups / series.
#' @param colors Optional override vector supplied by the user or from
#'   `getOption("highdir.colors")`. If non-NULL and long enough, it is used
#'   directly.
#' @return Character vector of length `n`.
#' @keywords internal
resolve_colors <- function(n, colors = NULL) {
  # Prefer explicit override
  user_colors <- colors %||% getOption("highdir.colors", default = NULL)
  if (!is.null(user_colors) && length(user_colors) >= n)
    return(user_colors[seq_len(n)])

  # Built-in palette rules (mirror make_hist logic)
  if (n == 2) {
    return(c("rgba(49,101,117,1)", "rgba(138,41,77,1)"))
  } else if (n <= length(.hdir_colors)) {
    return(.hdir_colors[seq_len(n)])
  } else {
    return(viridis::viridis(n, option = "D"))
  }
}

# ---------------------------------------------------------------------------
# Line symbol helpers
# ---------------------------------------------------------------------------

#' Available Highcharts marker symbols
#' @keywords internal
.hc_symbols <- c("circle", "square", "diamond", "triangle", "triangle-down")

#' Resolve and validate line symbols for n groups
#'
#' @param n Integer. Number of groups.
#' @param symbols Character vector or NULL supplied by the user.
#' @return Character vector of length `n`.
#' @keywords internal
resolve_symbols <- function(n, symbols = NULL) {
  if (is.null(symbols)) {
    return(rep(.hc_symbols, length.out = n))
  }
  invalid <- setdiff(symbols, .hc_symbols)
  if (length(invalid) > 0) {
    warning(
      "Invalid marker symbol(s): ", paste(invalid, collapse = ", "),
      ". Valid options: ", paste(.hc_symbols, collapse = ", "),
      ". Using default symbols."
    )
    return(rep(.hc_symbols, length.out = n))
  }
  if (length(symbols) != n) {
    warning(
      "Number of symbols (", length(symbols), ") does not match ",
      "number of groups (", n, "). Recycling symbols."
    )
  }
  rep(symbols, length.out = n)
}

# ---------------------------------------------------------------------------
# Argument validation helpers
# ---------------------------------------------------------------------------

#' Stop with a tidy message if columns are missing from a data frame
#' @keywords internal
check_columns <- function(data, cols, arg_name = "data") {
  missing <- setdiff(cols[!is.null(cols)], names(data))
  if (length(missing) > 0)
    stop("Column(s) not found in `", arg_name, "`: ",
         paste(missing, collapse = ", "), call. = FALSE)
}

#' Validate ylim argument
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
