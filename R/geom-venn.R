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
# is unused by both gg_venn and hc_venn.
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
#   hd(data.frame(), backend = "highcharter") +
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

  sets <- geom_params$sets
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

    fit  <- eulerr::euler(named_vals)

    # plot.euler() returns an eulergram (a gTree / grob), NOT a ggplot.
    # ggplot2::ggplotGrob() only accepts ggplot objects and errors on grobs.
    # The correct way to embed any grob into a ggplot layer is
    # annotation_custom(), which wraps it in an Annotation layer that the
    # engine can attach with `+` like any other layer.
    # Inf/-Inf extents make it fill the entire plot panel.
    euler_grob <- plot(fit, quantities = TRUE)

    return(list(
      ggplot2::annotation_custom(
        grob   = euler_grob,
        xmin   = -Inf, xmax = Inf,
        ymin   = -Inf, ymax = Inf
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

  sets            <- geom_params$sets
  series_name     <- geom_params$series_name     %||% "Venn Diagram"
  label_font_size <- geom_params$label_font_size %||% "14px"

  .validate_venn_sets(sets)

  # Highcharts expects each entry as a plain list - our sets list already
  # matches this format exactly, so no transformation needed.
  # We only ensure `value` is numeric (not integer) to avoid JSON issues.
  hc_data <- lapply(sets, function(entry) {
    entry$value <- as.numeric(entry$value)
    entry
  })

  chart |>
    highcharter::hc_chart(type = "venn") |>
    highcharter::hc_add_series(
      name       = series_name,
      data       = hc_data,
      dataLabels = list(
        style = list(fontSize = label_font_size)
      )
    )
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
#' hd(data.frame(), backend = "highcharter") +
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
#' \donttest{
#' # Build the set list with helper constructors
#' my_sets <- list(
#'   hd_venn_set("A", "Animals",    value = 5),
#'   hd_venn_set("B", "Four legs",  value = 4),
#'   hd_venn_set("C", "Mineral",    value = 2),
#'   hd_venn_intersect(c("A", "B"), value = 3)
#' )
#'
#' # Highcharter (interactive)
#' hd(data.frame(), backend = "highcharter") +
#'   hd_geom_venn(sets = my_sets) +
#'   hd_opts(title = "Animals and Minerals")
#'
#' # ggplot2 (static) - requires eulerr or ggVennDiagram
#' hd(data.frame(), backend = "ggplot2") +
#'   hd_geom_venn(sets = my_sets) +
#'   hd_opts(title = "Animals and Minerals")
#'
#' # Extend a base list programmatically
#' base_sets <- list(
#'   hd_venn_set("A", "Oslo",   value = 120),
#'   hd_venn_set("B", "Bergen", value = 95)
#' )
#' extended <- c(base_sets, list(
#'   hd_venn_intersect(c("A", "B"), value = 40)
#' ))
#' hd(data.frame(), backend = "highcharter") +
#'   hd_geom_venn(sets = extended) +
#'   hd_opts(title = "City overlap")
#' }
#'
#' @export
hd_geom_venn <- function(sets,
                          series_name     = "Venn Diagram",
                          label_font_size = "14px",
                          ...) {
  # Validate at construction time - fail early before the object is even stored
  .validate_venn_sets(sets, "hd_geom_venn")

  hd_geom("venn",
          sets            = sets,
          series_name     = series_name,
          label_font_size = label_font_size,
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
