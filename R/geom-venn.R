# Venn / Euler diagram geometry
#
# Data contract
# -------------
# Unlike every other highdir geom, venn/euler diagrams cannot be described
# by a flat spec$x / spec$y column mapping.  The data is a *list of set
# entries*, where each entry describes either:
#
#   - a single set:      list(sets = list("A"), name = "Animals", value = 5)
#   - an intersection:   list(sets = list("A", "B"), value = 2)
#
# This list is supplied directly in hd_geom_venn(sets = ...) rather than
# via hd_spec().  hd_spec() is still required by hd() but its $data slot
# is unused by both gg_venn and hc_venn. Else use hd_spec_venn() to wrap
# the sets list in a spec object for use with hd_make().
#
# Why skip_base_fig = TRUE?
# -----------------------
# The registry marks venn with skip_base_fig = TRUE so the engine bypasses
# base_fig().  base_fig() builds an x/y axis canvas from spec$x/spec$y --
# that canvas is meaningless for venn diagrams, which have no axes.
# The self-contained path (same as map geoms) gives both gg_venn and
# hc_venn a blank canvas to build from scratch.
#
# Extending the set list
# ----------------------
# Users can build the sets list programmatically:
#
#   base_sets <- list(
#     list(sets = list("A"), name = "Group A", value = 10),
#     list(sets = list("B"), name = "Group B", value = 8)
#   )
#   # Add an intersection entry:
#   extended <- c(base_sets, list(
#     list(sets = list("A", "B"), value = 4)
#   ))
#   hd(backend = "highcharter") +
#     hd_geom_venn(sets = extended) +
#     hd_opts(title = "Overlap")
#
# hd_venn_set() and hd_venn_intersect() are helper constructors that make
# building the list less error-prone (see bottom of this file).


# =============================================================================
# Input validation
# =============================================================================

#' @keywords internal
.validate_venn_sets <- function(sets, call_name = "hd_geom_venn") {

  if (!is.list(sets) || length(sets) == 0L)
    stop(call_name, "(): `sets` must be a non-empty list.", call. = FALSE)

  for (i in seq_along(sets)) {
    entry <- sets[[i]]

    if (!is.list(entry))
      stop(call_name, "(): sets[[", i, "]] must be a named list.",
           call. = FALSE)

    if (is.null(entry$sets) || !is.list(entry$sets) || length(entry$sets) == 0L)
      stop(call_name, "(): sets[[", i, "]]$sets must be a non-empty list of ",
           "character set names.  E.g. list('A') or list('A', 'B').",
           call. = FALSE)

    if (!all(vapply(entry$sets, is.character, logical(1))))
      stop(call_name, "(): sets[[", i, "]]$sets must contain character strings.",
           call. = FALSE)

    if (is.null(entry$value) || !is.numeric(entry$value) || length(entry$value) != 1L)
      stop(call_name, "(): sets[[", i, "]]$value must be a single numeric.",
           call. = FALSE)
  }

  invisible(NULL)
}


# =============================================================================
# gg_venn  --  ggplot2 backend
# =============================================================================

#' ggplot2 Venn/Euler Geom Function
#'
#' Renders a Venn or Euler diagram using the \pkg{eulerr} package (preferred)
#' or \pkg{ggVennDiagram} as a fallback.  Both are in `Suggests` -- the
#' function degrades gracefully with an informative message if neither is
#' installed.
#'
#' @param spec       An [hd_spec()] object.  `$data` is not used; only
#'   `geom_params$sets` carries the diagram data.
#' @param opts       An [hd_opts()] object.
#' @param geom_params Named list.  Must contain `sets` (the set list).
#'
#' @return A list of ggplot2 layers / grob wrapped in a list for the engine.
#' @keywords internal
gg_venn <- function(spec, opts, geom_params, ...) {
  
  # Sets resolution: two paths depending on calling API.
  #
  # Composable API (hd() + hd_geom_venn(sets = ...)):
  #   sets live in geom_params$sets -- supplied by the user directly.
  #
  # Declarative API (hd_spec_venn() + hd_make(spec, "venn", opts, sets = ...)):
  #   sets are passed via ... into geom_params by hd_make(), same pattern
  #   as ymin/ymax for arearange.  But as a convenience, if geom_params$sets
  #   is NULL and spec is an hd_spec_venn, extract sets from spec automatically
  #   so hd_make(spec_v, "venn", opts) works without repeating the sets.
  sets         <- geom_params$sets %||%
    if (inherits(spec, "hd_spec_venn")) hd_venn_sets_from_spec(spec) else NULL

  .validate_venn_sets(sets)

  # -- eulerr path (preferred) -------------------------------------------------
  if (requireNamespace("eulerr", quietly = TRUE)) {

    # Convert the highdir sets list -> named numeric vector for eulerr::euler()
    # Single sets:      list(sets=list("A"), value=5) -> c(A = 5)
    # Intersections:    list(sets=list("A","B"), value=2) -> c("A&B" = 2)
    named_vals <- vapply(sets, function(e) e$value, numeric(1))
    set_keys   <- vapply(sets, function(e) {
      paste(unlist(e$sets), collapse = "&")
    }, character(1))
    names(named_vals) <- set_keys

    fit          <- eulerr::euler(named_vals)
    value_suffix <- geom_params$value_suffix %||% ""

    # Resolve colours ----------------------------------------------------------
    setv <- set_keys[grep("&", set_keys, invert = TRUE)]  # single sets only
    pal <- resolve_colors(length(setv), NULL)

    
    
    # Build per-region label text:
    #   default:                 "42"
    #   with value_suffix "%":   "42%"
    #   with extra column n:     "42%(n=312)"
    # eulerr accepts a named character vector for `quantities` where names
    # match the region keys (e.g. "A", "A&B").
    quantities_labels <- vapply(sets, function(e) {
      key     <- paste(unlist(e$sets), collapse = "&")
      val_str <- paste0(e$value, value_suffix)

      # Append extra columns as (key=value) pairs after the value
      extra_str <- ""
      if (!is.null(e$extra) && length(e$extra) > 0L) {
        parts     <- paste(names(e$extra), unlist(e$extra), sep = "=")
        extra_str <- paste0("(", paste(parts, collapse = ", "), ")")
      }
      stats::setNames(paste0(val_str, extra_str), key)
    }, character(1))

    # plot.euler() returns an eulergram grob — embed via annotation_custom()
    euler_grob <- plot(
      fit,
      quantities = list(
        labels = quantities_labels,
        cex    = 1
      ),
      fills  = pal,
    )

    return(list(
      ggplot2::annotation_custom(
        grob = euler_grob,
        xmin = -Inf, xmax = Inf,
        ymin = -Inf, ymax = Inf
      )
    ))

  }

  # -- ggVennDiagram fallback --------------------------------------------------
  if (requireNamespace("ggVennDiagram", quietly = TRUE)) {

    # ggVennDiagram expects a named list of character vectors (set members).
    # We recover member-level data from single-set entries using seq_len(value).
    single_sets <- Filter(function(e) length(e$sets) == 1L, sets)
    set_members <- setNames(
      lapply(single_sets, function(e)
        as.character(seq_len(e$value))
      ),
      vapply(single_sets, function(e) e$sets[[1L]], character(1))
    )

    # Apply intersections by sharing member ids between sets
    inter_sets <- Filter(function(e) length(e$sets) > 1L, sets)
    for (entry in inter_sets) {
      n_shared <- as.integer(entry$value)
      grp_a    <- entry$sets[[1L]]
      grp_b    <- entry$sets[[2L]]
      if (!is.null(set_members[[grp_a]]) && !is.null(set_members[[grp_b]])) {
        shared_ids <- paste0("shared_", grp_a, "_", grp_b, "_",
                             seq_len(n_shared))
        set_members[[grp_a]] <- c(set_members[[grp_a]], shared_ids)
        set_members[[grp_b]] <- c(set_members[[grp_b]], shared_ids)
      }
    }

    # ggVennDiagram returns a proper ggplot object, so ggplotGrob() is
    # not needed.  Return it directly as a complete ggplot — the engine
    # will print it rather than try to add it as a layer.
    p <- ggVennDiagram::ggVennDiagram(set_members) +
      ggplot2::labs(title    = opts$title,
                    subtitle = opts$subtitle)

    return(list("__ggplot__" = p))
  }

  # -- neither package available -----------------------------------------------
  message(
    "hd_geom_venn(): ggplot2 backend requires 'eulerr' (preferred) or ",
    "'ggVennDiagram'.\n",
    "Install one: install.packages('eulerr')"
  )
  list(ggplot2::geom_blank())
}


# =============================================================================
# hc_venn  --  highcharter backend
# =============================================================================

#' Highcharter Venn/Euler Geom Function
#'
#' Adds a `"venn"` type series to a Highcharts chart.  Supports any number
#' of sets and any number of intersection entries.
#'
#' @section Highcharts venn series contract:
#' Each entry in `sets` becomes one element of the Highcharts `data` array:
#' \itemize{
#'   \item Single set: `list(sets = list("A"), name = "Animals", value = 5)`
#'   \item Intersection: `list(sets = list("A", "B"), value = 2)`
#' }
#' `name` is optional for intersections but required for single sets if you
#' want a label in the diagram.
#'
#' @section Venn vs Euler:
#' Supply only the intersections that actually exist in
#' your data. Highcharts will separate circles that share no intersection
#' entry, producing an Euler diagram automatically. No separate geom is
#' needed. Note: mathematically impossible layouts (e.g. three pairs all
#' intersect but the triple intersection is zero) cannot be rendered and will
#' error. If chart fails to display as intended, it might be due to the
#' intersection is larger than the single sets that contain them.
#' 
#' @param chart       A `highchart` object (from base_fig() bypass path).
#' @param spec        An [hd_spec()] object.  `$data` is unused.
#' @param opts        An [hd_opts()] object.
#' @param geom_params Named list.  Must contain `sets`; optionally
#'   `series_name` and `label_font_size`.
#' @param use_js      Logical. Unused for venn; present for engine consistency.
#' @param ...         Unused.
#'
#' @return The updated `highchart` object.
#' @keywords internal
hc_venn <- function(chart, spec, opts, geom_params, use_js = TRUE, ...) {

  # Sets resolution: geom_params$sets preferred; fallback to hd_spec_venn.
  sets            <- geom_params$sets %||%
    if (inherits(spec, "hd_spec_venn")) hd_venn_sets_from_spec(spec) else NULL
  series_name     <- geom_params$series_name     %||% "Venn Diagram"
  label_font_size <- geom_params$label_font_size %||% "14px"
  value_suffix    <- geom_params$value_suffix    %||% ""

  .validate_venn_sets(sets)

  # -- Resolve highdir palette -------------------------------------------------
  # The skip_base_fig path in backend-highcharter.R applies hd_theme() AFTER
  # hc_venn returns, so colors from opts are available here already.
  # We resolve the palette and assign one color per single-set entry.
  # Intersection regions are left uncolored (Highcharts blends them).
  single_set_entries <- Filter(function(e) length(e$sets) == 1L, sets)
  n_sets             <- length(single_set_entries)
  palette            <- resolve_colors(n_sets, opts$colors)

  # Map set id -> color so we can assign color per single-set entry
  set_ids     <- vapply(single_set_entries, function(e) e$sets[[1L]], character(1))
  color_map   <- stats::setNames(palette, set_ids)

  # -- Build the Highcharts data array -----------------------------------------
  # Each entry matches the Highcharts venn data contract:
  #   { sets: ["A"], name: "Oslo", value: 120, color: "#025169" }
  # Extra fields from entry$extra are promoted to top-level properties so
  # they are accessible inside tooltip formatters as this.point.n etc.
  #
  # BUG FIXED: previously extra fields were accessed as this.n in JS but
  # Highcharts tooltip formatters require this.point.n for custom properties.
  hc_data <- lapply(sets, function(entry) {
    out       <- entry
    out$value <- as.numeric(entry$value)

    # Assign color to single-set entries from the highdir palette.
    # Intersection entries get no explicit color — Highcharts blends
    # the colors of the overlapping sets automatically.
    if (length(entry$sets) == 1L) {
      sid <- entry$sets[[1L]]
      if (!is.null(color_map[[sid]]))
        out$color <- color_map[[sid]]
    }

    # Promote extra columns to top-level so Highcharts can access them.
    # Access pattern in JS: this.point.n  (NOT this.n)
    if (!is.null(entry$extra)) {
      for (nm in names(entry$extra))
        out[[nm]] <- entry$extra[[nm]]
    }
    out$extra <- NULL
    out
  })

  # -- Detect what the tooltip needs to show -----------------------------------
  has_suffix <- nchar(value_suffix) > 0L
  extra_keys <- unique(unlist(lapply(sets, function(e) names(e$extra))))
  has_extras <- length(extra_keys) > 0L

  # -- Tooltip formatter -------------------------------------------------------
  # Always build a formatter so we control the exact layout:
  #   Name: value%        (first line — name + value + optional suffix)
  #   n = 312             (one line per extra column)
  #
  # FIX 1: extra fields accessed as this.point.n not this.n
  # FIX 2: formatter always injected so the default Highcharts tooltip
  #         (which ignores custom properties) does not show instead
  extra_lines_js <- if (has_extras) {
    lines <- vapply(extra_keys, function(k) {
      sprintf(
        "if (typeof this.point.%s !== 'undefined') rows.push('%s = ' + this.point.%s);",
        k, k, k
      )
    }, character(1))
    paste(lines, collapse = "
        ")
  } else ""

  tooltip_js <- highcharter::JS(sprintf(
    "function() {
      var suffix = '%s';
      var val    = this.point.value;
      var name   = this.point.name || this.point.sets.join(' + ');
      var rows   = ['<b>' + name + '</b>: ' + val + suffix];
      %s
      return rows.join('<br/>');
    }",
    value_suffix,
    extra_lines_js
  ))

  # -- dataLabels formatter ----------------------------------------------------
  # Region label shown inside each circle / intersection area.
  # Format:  value%          (no extra)
  #          value%(n=312)   (with extra columns)
  #
  # Extra columns appended inline: value%(n=312, pct=0.15)
  # Uses this.point.n to access custom properties (same fix as tooltip).
  dl_extra_js <- if (has_extras) {
    parts <- vapply(extra_keys, function(k) {
      sprintf("(typeof this.point.%s !== 'undefined' ? '%s=' + this.point.%s : '')", k, k, k)
    }, character(1))
    # Join non-empty parts with comma separator
    paste0(
      "
      var extras = [", paste(parts, collapse = ", "), "].filter(function(s){return s !== '';});
",
      "      var extra_str = extras.length > 0 ? '(' + extras.join(', ') + ')' : '';"
    )
  } else "
      var extra_str = '';"

  dl_formatter <- highcharter::JS(sprintf(
    "function() {
      var suffix = '%s';
      var val    = this.point.value;
      var name   = this.point.name || this.point.sets.join('+');
      %s
      return '<b>' + name + '</b><br/>' + val + suffix + extra_str;
    }",
    value_suffix,
    dl_extra_js
  ))

  data_labels <- list(
    enabled   = TRUE,
    style     = list(fontSize = label_font_size),
    formatter = dl_formatter
  )

  # -- Add series with type = "venn" on the series itself ----------------------
  # FIX: hc_chart(type = "venn") does not work after hc_add_series because
  # Highcharts uses the series-level type, not the chart-level type for venn.
  # Setting type directly on hc_add_series is the correct approach.
  chart <- chart |>
    highcharter::hc_add_series(
      type       = "venn",
      name       = series_name,
      data       = hc_data,
      dataLabels = data_labels
    ) |>
    highcharter::hc_tooltip(
      formatter = tooltip_js,
      useHTML   = TRUE
    )

  chart
}


# =============================================================================
# Public constructor
# =============================================================================

#' Venn / Euler Diagram Layer for hd Objects
#'
#' Creates a Venn or Euler diagram layer that is added to an [hd()] object
#' via `+`.  The diagram is described by a list of set entries supplied via
#' the `sets` argument.
#'
#' @section Data format:
#' `sets` is a list of named lists.  Each element describes either a single
#' set or an intersection between sets:
#'
#' ```r
#' list(
#'   # Single sets - must have name and value
#'   list(sets = list("A"), name = "Animals",   value = 5),
#'   list(sets = list("B"), name = "Four legs", value = 4),
#'   list(sets = list("C"), name = "Mineral",   value = 2),
#'   # Intersections - sets contains two or more names, value is overlap size
#'   list(sets = list("A", "B"), value = 3)
#' )
#' ```
#'
#' Use [hd_venn_set()] and [hd_venn_intersect()] to build entries without
#' typing the nested list structure by hand.
#'
#' @section Extending the set list:
#' Because `sets` is a plain R list, it can be built and extended
#' programmatically with `c()` or `append()`:
#'
#' ```r
#' base <- list(
#'   hd_venn_set("A", "Animals",   5),
#'   hd_venn_set("B", "Four legs", 4)
#' )
#' extended <- c(base, list(hd_venn_intersect(c("A","B"), 3)))
#' hd(backend = "highcharter") +
#'   hd_geom_venn(sets = extended)
#' ```
#'
#' @section Backend differences:
#' \describe{
#'   \item{highcharter}{Uses Highcharts' native `"venn"` series type.
#'     All features (labels, tooltips, interactivity) work out of the box.
#'     `series_name` and `label_font_size` are highcharter-only options.}
#'   \item{ggplot2}{Requires the \pkg{eulerr} package (preferred) or
#'     \pkg{ggVennDiagram} in `Suggests`.  Install with
#'     `install.packages("eulerr")`.}
#' }
#'
#' @param sets          A list of set entries.  See **Data format** above.
#'   Use [hd_venn_set()] and [hd_venn_intersect()] to build entries.
#' @param series_name   Character. Series label shown in the Highcharts
#'   chart.  Default `"Venn Diagram"`.  Highcharter only.
#' @param label_font_size Character. CSS font-size for set labels.
#'   Default `"14px"`.  Highcharter only.
#' @param ...           Additional arguments forwarded to [hd_make()].
#'
#' @return An S3 object of class `"hd_geom"` for use with `+.hd`.
#'
#' @seealso [hd_venn_set()], [hd_venn_intersect()]
#'
#' @examples
#' # Build the set list with helper constructors
#' my_sets <- list(
#'   hd_venn_set("A", "Animals",    value = 5),
#'   hd_venn_set("B", "Four legs",  value = 4),
#'   hd_venn_set("C", "Mineral",    value = 2),
#'   hd_venn_intersect(c("A", "B"), value = 3)
#' )
#'
#' # Highcharter (interactive)
#' hd(backend = "highcharter") +
#'   hd_geom_venn(sets = my_sets) +
#'   hd_opts(title = "Animals and Minerals")
#'
#' # ggplot2 (static) - requires eulerr or ggVennDiagram
#' hd(backend = "ggplot2") +
#'   hd_geom_venn(sets = my_sets) +
#'   hd_opts(title = "Animals and Minerals")
#'
#' # Extend a base list programmatically
#' base_sets <- list(
#'   hd_venn_set("A", "Oslo",   value = 120),
#'   hd_venn_set("B", "Bergen", value = 95)
#' )
#' extended <- c(base_sets, list(
#'   hd_venn_intersect(c("A", "B"), "Both", value = 40)
#' ))
#' hd(backend = "highcharter") +
#'   hd_geom_venn(sets = extended) +
#'   hd_opts(title = "City overlap")
#'
#' @export
hd_geom_venn <- function(sets,
                         series_name     = "Venn Diagram",
                         label_font_size = "14px",
                         value_suffix    = "",
                         ...) {
  # Validate at construction time - fail early before the object is even stored
  .validate_venn_sets(sets, "hd_geom_venn")

  hd_geom("venn",
          sets            = sets,
          series_name     = series_name,
          label_font_size = label_font_size,
          value_suffix    = value_suffix,
          ...)
}


# =============================================================================
# Helper constructors - build set entries without nested list typing
# =============================================================================

#' Build a Single-Set Entry for hd_geom_venn
#'
#' Creates one set entry describing a single, non-overlapping set region.
#' Pass the result directly into the `sets` list of [hd_geom_venn()].
#'
#' @param id    Character. Short identifier used to reference this set in
#'   intersection entries.  E.g. `"A"`.
#' @param name  Character. Human-readable label shown inside the circle.
#' @param value Numeric. Area / size of this set region (excluding overlaps).
#'
#' @return A named list suitable for inclusion in the `sets` argument of
#'   [hd_geom_venn()].
#'
#' @examples
#' hd_venn_set("A", "Animals", 5)
#' #> list(sets = list("A"), name = "Animals", value = 5)
#'
#' @export
hd_venn_set <- function(id, name, value) {
  if (!is.character(id)   || length(id) != 1L)
    stop("hd_venn_set(): `id` must be a single character string.", call. = FALSE)
  if (!is.character(name) || length(name) != 1L)
    stop("hd_venn_set(): `name` must be a single character string.", call. = FALSE)
  if (!is.numeric(value)  || length(value) != 1L)
    stop("hd_venn_set(): `value` must be a single number.", call. = FALSE)

  list(sets = list(id), name = name, value = as.numeric(value))
}


#' Build an Intersection Entry for hd_geom_venn
#'
#' Creates one entry describing the overlap region between two or more sets.
#' The `ids` must match the `id` values used in the corresponding
#' [hd_venn_set()] calls.
#'
#' @param ids   Character vector of length >= 2 identifying the overlapping
#'   sets.  E.g. `c("A", "B")` for the A-B intersection.
#' @param value Numeric. Area / size of the intersection region.
#' @param name  Character or `NULL`.  Optional label for the intersection
#'   region.  Usually left `NULL`.
#'
#' @return A named list suitable for inclusion in the `sets` argument of
#'   [hd_geom_venn()].
#'
#' @examples
#' hd_venn_intersect(c("A", "B"), value = 2)
#' #> list(sets = list("A", "B"), value = 2)
#'
#' @export
hd_venn_intersect <- function(ids, value, name = NULL) {
  if (!is.character(ids) || length(ids) < 2L)
    stop("hd_venn_intersect(): `ids` must be a character vector of length >= 2.",
         call. = FALSE)
  if (!is.numeric(value) || length(value) != 1L)
    stop("hd_venn_intersect(): `value` must be a single number.", call. = FALSE)

  entry <- list(sets = as.list(ids), value = as.numeric(value))
  if (!is.null(name)) entry$name <- name
  entry
}


# =============================================================================
# venn_df_to_list()  -- data.frame to venn set list converter
# =============================================================================

#' Convert a Data Frame to a Venn Set List
#'
#' Converts a tidy data frame with columns `id`, `name`, `value`, and `type`
#' into the nested list format required by [hd_geom_venn()] and
#' [hd_spec_venn()].  This is the recommended way to build venn data from
#' a spreadsheet, CSV, or database query without calling [hd_venn_set()] and
#' [hd_venn_intersect()] row by row.
#'
#' @section Data frame format:
#' The input data frame must have these four columns:
#' \describe{
#'   \item{`id`}{Character. For `type = "set"`: a single identifier such as
#'     `"A"`.  For `type = "intersect"`: a comma-separated list of the set ids
#'     that overlap, such as `"A,B"` or `"A,B,C"`.  Spaces around commas are
#'     trimmed automatically.}
#'   \item{`name`}{Character. Human-readable label shown in the diagram.
#'     For intersections this is optional — supply `NA` or `""` to omit it.}
#'   \item{`value`}{Numeric. Area or size of this region.}
#'   \item{`type`}{Character. Either `"set"` (a single circle) or
#'     `"intersect"` (an overlap region between two or more circles).}
#' }
#'
#' @section Relationship to hd_venn_set / hd_venn_intersect:
#' Each row is converted by the corresponding constructor:
#' \itemize{
#'   \item `type = "set"`      calls [hd_venn_set(id, name, value)]
#'   \item `type = "intersect"` calls [hd_venn_intersect(ids, value, name)]
#'     where `ids` is the comma-split vector from `id`.
#' }
#' The result is identical to building the list by hand with those functions.
#'
#' @param df  A data frame with columns `id`, `name`, `value`, `type`.
#'   Can be a plain `data.frame`, `data.table`, or `tibble`.
#'
#' @return A list of set entries suitable for [hd_geom_venn()],
#'   [hd_spec_venn()], and [hd_venn_df()].
#'
#' @seealso [hd_venn_df()], [hd_spec_venn()], [hd_geom_venn()]
#'
#' @examples
#' venn_df <- data.frame(
#'   type  = c("set", "set", "intersect"),
#'   id    = c("A",   "B",   "A,B"),
#'   name  = c("Oslo", "Bergen", "Both"),
#'   value = c(120, 95, 40)
#' )
#'
#' sets <- venn_df_to_list(venn_df)
#' # Equivalent to:
#' # list(
#' #   hd_venn_set("A", "Oslo",   120),
#' #   hd_venn_set("B", "Bergen", 95),
#' #   hd_venn_intersect(c("A", "B"), 40, name = "Both")
#' # )
#'
#' @export
venn_df_to_list <- function(df) {

  # -- Input validation --------------------------------------------------------
  if (!is.data.frame(df))
    stop("venn_df_to_list(): `df` must be a data.frame.", call. = FALSE)

  required_cols <- c("id", "name", "value", "type")
  missing_cols  <- setdiff(required_cols, names(df))
  if (length(missing_cols))
    stop("venn_df_to_list(): `df` is missing column(s): ",
         paste(missing_cols, collapse = ", "), ".", call. = FALSE)

  if (nrow(df) == 0L)
    stop("venn_df_to_list(): `df` has no rows.", call. = FALSE)

  valid_types <- c("set", "intersect")
  bad_types   <- setdiff(unique(as.character(df$type)), valid_types)
  if (length(bad_types))
    stop("venn_df_to_list(): `type` column contains unknown value(s): ",
         paste(bad_types, collapse = ", "),
         ".  Use \"set\" or \"intersect\".", call. = FALSE)

  # -- Detect extra columns ----------------------------------------------------
  # Any column beyond the four required ones is treated as an "extra" column.
  # Extra columns are stored per-entry in entry$extra = list(col = value).
  # They are rendered as tooltip rows in highcharter and appended to region
  # labels in ggplot2.  Typical use: n = sample count shown alongside %.
  reserved_cols <- c("id", "name", "value", "type")
  extra_cols    <- setdiff(names(df), reserved_cols)

  # -- Row-by-row conversion ---------------------------------------------------
  # Work on a plain data.frame copy so the function accepts data.table and
  # tibble inputs without requiring those packages.
  df <- as.data.frame(df, stringsAsFactors = FALSE)

  lapply(seq_len(nrow(df)), function(i) {
    row  <- df[i, , drop = FALSE]
    type <- trimws(as.character(row$type))
    id   <- as.character(row$id)
    nm   <- as.character(row$name)
    val  <- as.numeric(row$value)

    if (type == "set") {
      # Single-set row: id is a plain identifier, name is required
      entry <- hd_venn_set(id = trimws(id), name = nm, value = val)

    } else {
      # Intersect row: id is comma-separated, e.g. "A,B" or "A, B, C"
      ids <- trimws(strsplit(id, ",", fixed = TRUE)[[1L]])
      if (length(ids) < 2L)
        stop("venn_df_to_list(): row ", i,
             " has type \"intersect\" but `id` contains only one value (\"",
             id, "\").  Supply comma-separated ids, e.g. \"A,B\".",
             call. = FALSE)

      # name is optional for intersections -- omit when NA or empty string
      nm_clean <- if (is.na(nm) || nchar(trimws(nm)) == 0L) NULL else nm
      entry    <- hd_venn_intersect(ids = ids, value = val, name = nm_clean)
    }

    # Attach extra columns as entry$extra = list(col1 = val1, col2 = val2)
    # This is a named list of scalar values, one element per extra column.
    # Both hc_venn and gg_venn read entry$extra to enrich tooltips/labels.
    if (length(extra_cols) > 0L) {
      entry$extra <- setNames(
        lapply(extra_cols, function(col) row[[col]]),
        extra_cols
      )
    }

    entry
  })
}


# =============================================================================
# hd_venn_df()  -- convenience wrappers for both APIs
# =============================================================================

#' Create a Venn Diagram Directly from a Data Frame
#'
#' A single-call convenience wrapper that accepts the same tidy data frame as
#' [venn_df_to_list()] and returns either an `hd_spec_venn` object (for the
#' declarative API) or an `hd_geom` layer (for the composable `+` API),
#' depending on the `output` argument.
#'
#' This means you never need to call [venn_df_to_list()], [hd_spec_venn()],
#' or [hd_geom_venn()] directly when starting from a data frame.
#'
#' @section Which output to use:
#' \describe{
#'   \item{`output = "spec"` (default)}{Returns an `hd_spec_venn` object.
#'     Pass to [hd_make()] just like any other spec.  Best for reporting
#'     pipelines and scripts that separate data from presentation.}
#'   \item{`output = "geom"`}{Returns an `hd_geom` layer.  Add to an [hd()]
#'     object with `+`.  Best for interactive exploration and inline charts.}
#' }
#'
#' @section Declarative API (output = "spec"):
#' ```r
#' df <- data.frame(
#'   type  = c("set", "set", "intersect"),
#'   id    = c("A",   "B",   "A,B"),
#'   name  = c("Oslo", "Bergen", "Both"),
#'   value = c(120, 95, 40)
#' )
#'
#' spec_v <- hd_venn_df(df)
#' hd_make(spec_v, "venn", hd_opts(title = "City overlap"))
#' ```
#'
#' @section Composable API (output = "geom"):
#' ```r
#' hd(backend = "highcharter") +
#'   hd_venn_df(df, output = "geom") +
#'   hd_opts(title = "City overlap")
#' ```
#'
#' @param df            A data frame with columns `id`, `name`, `value`,
#'   `type`.  See [venn_df_to_list()] for the full format description.
#' @param output        Character. `"spec"` (default) returns an
#'   `hd_spec_venn`; `"geom"` returns an `hd_geom` layer for use with `+`.
#' @param series_name   Character. Passed to [hd_geom_venn()] when
#'   `output = "geom"`.  Default `"Venn Diagram"`.
#' @param label_font_size Character. Passed to [hd_geom_venn()] when
#'   `output = "geom"`.  Default `"14px"`.
#'
#' @return An `hd_spec_venn` object when `output = "spec"`, or an `hd_geom`
#'   object when `output = "geom"`.
#'
#' @seealso [venn_df_to_list()], [hd_spec_venn()], [hd_geom_venn()],
#'   [hd_make()], [hd()]
#'
#' @examples
#' \donttest{
#' df <- data.frame(
#'   type  = c("set", "set", "intersect"),
#'   id    = c("A",   "B",   "A,B"),
#'   name  = c("Oslo", "Bergen", "Both"),
#'   value = c(120, 95, 40)
#' )
#'
#' # Declarative API
#' spec_v <- hd_venn_df(df)
#' hd_make(spec_v, "venn", hd_opts(title = "City overlap"))
#'
#' # Composable API
#' hd(backend = "highcharter") +
#'   hd_venn_df(df, output = "geom") +
#'   hd_opts(title = "City overlap")
#'
#' # ggplot2 backend
#' hd(backend = "ggplot2") +
#'   hd_venn_df(df, output = "geom") +
#'   hd_opts(title = "City overlap")
#' }
#'
#' @export
hd_venn_df <- function(df,
                        output          = c("spec", "geom"),
                        series_name     = "Venn Diagram",
                        label_font_size = "14px",
                        value_suffix    = "") {

  output <- match.arg(output)
  sets   <- venn_df_to_list(df)

  if (output == "spec") {
    # For the declarative API, value_suffix is passed via hd_make() ...
    # Store it as an attribute on the spec so it travels with the object
    # and can be extracted by hd_make() and passed through to the geom.
    sv <- hd_spec_venn(sets)
    attr(sv, "value_suffix") <- value_suffix
    sv
  } else {
    hd_geom_venn(sets            = sets,
                 series_name     = series_name,
                 label_font_size = label_font_size,
                 value_suffix    = value_suffix)
  }
}
