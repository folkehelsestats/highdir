# Internal helpers (not exported)
#
# All small utilities used across the package live here so there is a single
# place to look for them.  Nothing in this file is exported.

# -- NULL coalescing -----------------------------------------------------------

#' @keywords internal
`%||%` <- function(a, b) if (is.null(a)) b else a

# -- Type predicates -----------------------------------------------------------

#' @keywords internal
is_highchart <- function(x) inherits(x, "highchart")

#' @keywords internal
is_ggplot <- function(x) inherits(x, c("gg", "ggplot"))

# -- Validation helpers --------------------------------------------------------

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
#' @param n Integer. Number of groups.
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
#'   NULL   -> hide the axis label entirely
#'   " "    -> use the column name from spec as the fallback
#'   string -> use the string as-is
#'
#' @param opts_label The value from hd_opts()$ylab or $xlab.
#' @param spec_col   The column name from hd_spec()$y or $x.
#' @return Character string or NULL.
#' @keywords internal
.resolve_axis_label <- function(opts_label, spec_col) {

  if (is.null(opts_label))
    return(NULL)          # explicit NULL -> hide

  if (identical(opts_label, " "))
    return(spec_col)      # sentinel -> use column name

  opts_label              # any other string -> use as-is
}


# -- Axis label hiding (applied AFTER theme) --------------------------------
# -- For ggplot2 ---------------------------------------------------------------
# .resolve_axis_label() is called again here (not just in base_fig) because:
#   1. gt$theme can overwrite element_blank() that base_fig() set earlier.
#   2. Geoms like ranked_bar bypass base_fig() entirely, so their labels
#      would never be set otherwise.
# Applying after gt$theme guarantees the resolved label always wins.
.apply_axis_label <- function(p, resolved, axis) {
  if (is.null(resolved)) {
    axis_blank <- stats::setNames(list(resolved), axis)
    p + do.call(ggplot2::labs, axis_blank)
  } else {
    # String -> set the label (covers both column-name fallback and custom text)
    axis_labs <- stats::setNames(list(resolved), axis)
    p + do.call(ggplot2::labs, axis_labs)
  }
}


# Round numeric column ---------------------------------------------------------
#' @keywords internal
round_column <- function(data, column, digits = 0) {
  # --- Validate dataset ---
  if (!is.data.frame(data)) {
    stop("`data` must be a data.frame.", call. = FALSE)
  }
  
  if (!column %in% names(data)) {
    stop(sprintf("Column '%s' does not exist in the dataset.", column),
         call. = FALSE)
  }
  
  # --- Validate digits ---
  if (length(digits) != 1 || is.na(digits)) {
    stop("`digits` must be a single non-NA numeric value.", call. = FALSE)
  }
  
  # Coerce digits safely
  digits_num <- suppressWarnings(as.numeric(digits))
  if (is.na(digits_num)) {
    stop("`digits` must be numeric.", call. = FALSE)
  }
  digits_int <- as.integer(round(digits_num))  # enforce integer
  
  # --- Validate column type ---
  col <- data[[column]]
  
  if (!is.numeric(col)) {
    stop(sprintf(
      "Column '%s' is not numeric (found class: %s). Cannot apply rounding.",
      column, paste(class(col), collapse = ", ")
    ),
    call. = FALSE)
  }
  
  # --- Perform rounding (safe, no mutation of input data) ---
  data[[column]] <- round(col, digits_int)
  
  # --- Return modified dataset ---
  return(data)
}

check_decimals <- function(spec, opts, type, extra_args){

  decs <- opts$decimals
  
  if (!is.null(decs))
    spec$data <- round_column(spec$data, spec$y, decs)

  if (type == "arearange" && !is.null(decs)){
    spec$data <- round_column(spec$data, extra_args$ymin, decs)
    spec$data <- round_column(spec$data, extra_args$ymax, decs)
  }
  
  return(spec)
}


#' Version-safe highcharter accessibility description setter
#'
#' highcharter 0.9.4 does not export hc_accessibility().
#' This wrapper patches chart$x$hc_opts$accessibility directly, which works across
#' all highcharter versions because hc_opts is the raw Highcharts config.
#'
#' @param chart A highchart object.
#' @param description Character. The accessibility description string.
#' @return The modified highchart object.
#' @keywords internal
.hd_accessibility <- function(chart, description) {
      # chart$x$hc_opts is the plain list serialised to JSON by htmlwidgets.
      # Setting accessibility$description here is equivalent to:
      #   Highcharts.chart({ accessibility: { description: "..." } })
      chart$x$hc_opts <- utils::modifyList(
        chart$x$hc_opts %||% list(),
        list(accessibility = list(description = description))
      )
      chart
}


# Validate that the geometry-specific arguments in hd_geom are compatible with
# the current backend. If any arguments are marked as backend-specific and the
# current backend doesn't match, issue a warning. This function is called
# immediately after adding a geom layer to an hd object, so that users get early
# feedback if they accidentally use a ggplot2-only argument while the backend is
# set to highcharter (or vice versa). The function looks up the geom type in the
# registry to find all its arguments, checks if any are marked as
# backend-specific, and if so, compares the current backend with the required
# one. If there's a mismatch and the user supplied a non-default value for that
# argument, it issues a warning that the argument will be ignored. This
# validation helps prevent silent failures where a user might set an argument
# that only applies to ggplot2 while using the highcharter backend, and then
# wonder why it has no effect. By warning them immediately, they can correct
# their code before proceeding further. The function does not stop execution; it
# only issues warnings for incompatible arguments. The actual rendering
# functions for each backend should also be designed to ignore any arguments
# that don't apply to them, so this validation is an additional user-friendly
# check rather than a strict enforcement mechanism. The function assumes that
# the geom registry entries have a structure where each argument's metadata
# includes a `backend_only` field that specifies if the argument is exclusive to
# a particular backend. It also assumes that the `hd_geom` object has a `type`
# field that identifies the geom type, and a `params` list that contains the
# user-supplied values for the geom arguments.
# 
#' @keywords internal
.validate_geom_backend <- function(hd_obj) {
  geom   <- hd_obj$geom
  be     <- hd_obj$backend
  params <- geom$params
  type   <- geom$type

  # Use .get_geom() - note the leading dot, matching registry.R line 109
  reg <- .get_geom(type)
  if (is.null(reg)) return(invisible(NULL))   # unknown geom - skip silently

  all_args <- c(
    reg$required_args %||% list(),
    reg$optional_args %||% list()
  )

  for (arg_name in names(all_args)) {
    arg_meta     <- all_args[[arg_name]]
    backend_only <- arg_meta$backend_only     # NULL if not set
    user_value   <- params[[arg_name]]
    def          <- arg_meta$default

    # Only warn when ALL of these are true:
    #   1. the arg declares a backend restriction
    #   2. the current backend is not that backend
    #   3. the user actually supplied a value for this arg
    #   4. the supplied value differs from the default (so default pass-through
    #      from the constructor does not trigger a spurious warning)
    if (!is.null(backend_only) &&
        be != backend_only &&
        !is.null(user_value) &&
        !identical(user_value, def)) {

      warning(
        "`", arg_name, " = \"", user_value, "\"` is only supported by the ",
        backend_only, " backend and will be ignored.\n",
        "Current backend is '", be, "'.",
        call. = FALSE
      )
    }
  }

  invisible(NULL)
}
