# R/geom-map.R  -- Choropleth map geometry
#
# Data contract
# -------------
# hd_spec(data, x = "hc-key", y = "value")
#   x  -- column whose values match the GeoJSON feature property used as the
#          join key (e.g. "hc-key" for Highcharts map collections, or any
#          property name present in the GeoJSON features).
#   y  -- column whose numeric values drive the choropleth fill colour.
#
# Required geom arg:
#   map_url  -- URL string pointing to a GeoJSON file.
#               Highcharts map collection base URL:
#               https://raw.githubusercontent.com/highcharts/map-collection-dist/
#               refs/heads/master/countries/no/no-all-all.geo.json
#
# Color convention
# ----------------
# Choropleth maps use a SEQUENTIAL two-color gradient (low -> high), not the
# categorical palette used by line/column/bar geoms.
#
# Resolution order for low_col / high_col:
#   1. Explicit geom args:  hd_geom_map(low_col = "#fff", high_col = "#025169")
#   2. opts$colors as a 2-element vector: hd_opts(colors = c("#fff", "#025169"))
#   3. Built-in highdir brand defaults: "#C6DBEF" (light) -> "#025169" (dark)
#
# skip_base_fig = TRUE
# --------------------
# Maps have no x/y axes.  The engine bypasses base_fig() and gives both
# hc_map and gg_map a blank canvas to build from scratch, exactly like venn
# and ranked_bar.
#
# modes 
# --------
# interactive: native Highcharts Maps series.  Fetches GeoJSON inside hc_map
#              so the user never calls fromJSON().
# static:      uses sf + geom_sf (both in Suggests).  Degrades gracefully
#              with a message if sf is not installed.
#
# Norway convenience helper
# -------------------------
# hd_map_no() returns the standard URL for the Norwegian municipality /
# county map from the Highcharts map collection, so users do not need to
# remember the raw GitHub URL.


# =============================================================================
# Default sequential palette for choropleth maps
# =============================================================================

.map_default_cols <- c(low = "#C6DBEF", high = "#025169")

#' Resolve the two choropleth colours (low, high) for a map geom
#'
#' Priority: explicit args > opts$colors (2-element) > built-in defaults.
#'
#' @keywords internal
.resolve_map_colors <- function(low_col, high_col, opts) {

  # 1. Explicit geom args take priority
  if (!is.null(low_col)  && nzchar(low_col)  &&
      !is.null(high_col) && nzchar(high_col))
    return(c(low = low_col, high = high_col))

  # 2. opts$colors as a 2-element vector
  if (!is.null(opts$colors) && length(opts$colors) >= 2L)
    return(c(low = opts$colors[[1L]], high = opts$colors[[2L]]))

  # 3. Built-in highdir brand sequential palette
  .map_default_cols
}


# =============================================================================
# GeoJSON helpers
# =============================================================================

#' Fetch a GeoJSON file from a URL and filter to map features
#'
#' Downloads the GeoJSON, keeps only Polygon and MultiPolygon features
#' (strips Point, LineString etc. that Highcharts Maps cannot render), and
#' returns the modified GeoJSON list ready for `hc_add_series(mapData = ...)`.
#'
#' Results are memoised for the R session so repeated calls to the same URL
#' do not re-download.
#'
#' @param url Character. URL of a GeoJSON file.
#' @return A list (parsed GeoJSON) with only polygon features.
#' @keywords internal
.fetch_geojson <- local({

  cache <- list()

  function(url) {

    if (!is.null(cache[[url]]))
      return(cache[[url]])

    if (!requireNamespace("jsonlite", quietly = TRUE))
      stop(
        "hc_map() requires the 'jsonlite' package to fetch GeoJSON.\n",
        "Install it: install.packages('jsonlite')",
        call. = FALSE
      )

    geojson <- tryCatch(
      jsonlite::fromJSON(url, simplifyVector = FALSE),
      error = function(e)
        stop("hd_geom_map(): failed to fetch GeoJSON from:\n  ", url,
             "\n  ", conditionMessage(e), call. = FALSE)
    )

    # Keep only renderable polygon features
    poly_types <- c("Polygon", "MultiPolygon")
    geojson$features <- Filter(
      function(f) f$geometry$type %in% poly_types,
      geojson$features
    )

    cache[[url]] <<- geojson
    geojson
  }
})


# =============================================================================
# hc_map  --  highcharter backend
# =============================================================================

#' Highcharter Map Geom Function
#'
#' Adds a choropleth map series to a blank `highchart()` object using
#' Highcharts Maps.  Not called directly — use [hd_geom_map()] or
#' `hd_make(..., type = "map", ...)`.
#'
#' @section Tooltip format:
#' The default tooltip shows `{point.name}: {point.value}`.
#' Override with `geom_params$tooltip_fmt`, e.g.
#' `"{point.name}: {point.value} %"`.
#'
#' @param chart       A blank `highchart()` object (from engine bypass path).
#' @param spec        An [hd_spec()] object.  `$x` = join-key column,
#'   `$y` = value column.
#' @param opts        An [hd_opts()] object.
#' @param geom_params Named list.  Required: `map_url`.  Optional: `join_by`,
#'   `series_name`, `value_suffix`, `low_col`, `high_col`, `tooltip_fmt`,
#'   `nav_enabled`.
#' @param use_js      Logical. Unused; present for engine-contract consistency.
#' @param ...         Unused.
#'
#' @return The updated `highchart` object.
#' @keywords internal
hc_map <- function(chart, spec, opts, geom_params, use_js = TRUE, ...) {

  # -- Required args -----------------------------------------------------------
  map_url <- geom_params$map_url
  if (is.null(map_url) || !nzchar(map_url))
    stop("hd_geom_map() requires `map_url`. ",
         "Supply the URL of a GeoJSON file.",
         call. = FALSE)

  # -- Optional args -----------------------------------------------------------
  join_by      <- geom_params$join_by      %||% "hc-key"
  series_name  <- geom_params$series_name  %||% opts$ylab %||% spec$y
  value_suffix <- geom_params$value_suffix %||% ""
  nav_enabled  <- isTRUE(geom_params$nav_enabled %||% TRUE)
  tooltip_fmt  <- geom_params$tooltip_fmt  %||%
    paste0("{point.name}: {point.value}", value_suffix)
  low_col      <- geom_params$low_col  %||% NULL
  high_col     <- geom_params$high_col %||% NULL

  # -- Resolve colours ---------------------------------------------------------
  cols <- .resolve_map_colors(low_col, high_col, opts)

  # -- Fetch and prepare GeoJSON -----------------------------------------------
  geojson <- .fetch_geojson(map_url)

  # -- Data --------------------------------------------------------------------
  d      <- spec$data
  x_col  <- spec$x    # join-key column in the data frame
  y_col  <- spec$y    # value column

  # Highcharts expects a list of named lists, one per row.
  # The join key must be a top-level property matching `join_by`.
  hc_data <- lapply(seq_len(nrow(d)), function(i) {
    pt        <- as.list(d[i, , drop = FALSE])
    # Ensure the join column is at the expected key name even if the
    # data frame column has a different name (rare but defensive)
    if (x_col != join_by)
      pt[[join_by]] <- pt[[x_col]]
    pt[["value"]] <- pt[[y_col]]
    pt
  })

  # -- Build chart -------------------------------------------------------------
  chart |>
    highcharter::hc_title(text    = opts$title    %||% "") |>
    highcharter::hc_subtitle(text = opts$subtitle %||% "") |>
    highcharter::hc_add_series(
      type     = "map",
      mapData  = geojson,
      data     = hc_data,
      joinBy   = join_by,
      value    = "value",
      name     = series_name
    ) |>
    highcharter::hc_colorAxis(
      minColor = cols[["low"]],
      maxColor = cols[["high"]]
    ) |>
    highcharter::hc_tooltip(
      pointFormat = tooltip_fmt
    ) |>
    highcharter::hc_mapNavigation(
      enabled         = nav_enabled,
      enableMouseWheelZoom = nav_enabled
    )
}


# =============================================================================
# gg_map  --  ggplot2 backend
# =============================================================================

#' ggplot2 Map Geom Function
#'
#' Renders a choropleth map using [sf::read_sf()] and [ggplot2::geom_sf()].
#' Requires the `sf` package (in Suggests).  Returns a message and a blank
#' grob if `sf` is not installed.
#'
#' @param spec       An [hd_spec()] object.
#' @param opts       An [hd_opts()] object.
#' @param geom_params Named list.  Required: `map_url`.  Optional: `join_by`,
#'   `low_col`, `high_col`, `value_suffix`.
#' @param ...        Unused.
#'
#' @return A ggplot object (via the `__ggplot__` sentinel).
#' @keywords internal
gg_map <- function(spec, opts, geom_params, ...) {

  # -- sf availability check ---------------------------------------------------
  if (!requireNamespace("sf", quietly = TRUE)) {
    message(
      "hd_geom_map(): the ggplot2 backend requires the 'sf' package.\n",
      "Install it: install.packages('sf')\n",
      "Use backend = 'highcharter' for maps without sf."
    )
    return(list(ggplot2::geom_blank()))
  }

  # -- Args --------------------------------------------------------------------
  map_url      <- geom_params$map_url
  if (is.null(map_url) || !nzchar(map_url))
    stop("hd_geom_map() requires `map_url`.", call. = FALSE)

  join_by      <- geom_params$join_by      %||% "hc-key"
  value_suffix <- geom_params$value_suffix %||% ""
  low_col      <- geom_params$low_col  %||% NULL
  high_col     <- geom_params$high_col %||% NULL

  cols <- .resolve_map_colors(low_col, high_col, opts)

  # -- Read spatial data -------------------------------------------------------
  sf_data <- tryCatch(
    sf::read_sf(map_url),
    error = function(e)
      stop("hd_geom_map(): failed to read GeoJSON from:\n  ", map_url,
           "\n  ", conditionMessage(e), call. = FALSE)
  )

  # -- Join user data to spatial features --------------------------------------
  d      <- spec$data
  x_col  <- spec$x
  y_col  <- spec$y

  # Find the matching column in the sf object (usually "hc.key" after sf
  # normalises the hyphen, or the literal join_by name)
  sf_key <- join_by
  # sf replaces hyphens with dots in column names
  sf_key_clean <- gsub("-", ".", join_by, fixed = TRUE)
  if (sf_key_clean %in% names(sf_data))
    sf_key <- sf_key_clean

  merged <- merge(
    sf_data,
    d,
    by.x = sf_key,
    by.y = x_col,
    all.x = TRUE
  )

  # -- Build ggplot ------------------------------------------------------------
  p <- ggplot2::ggplot(merged) +
    ggplot2::geom_sf(
      ggplot2::aes(fill = .data[[y_col]]),
      colour    = "white",
      linewidth = 0.2
    ) +
    ggplot2::scale_fill_gradient(
      low      = cols[["low"]],
      high     = cols[["high"]],
      na.value = "#D3D3D3",
      name     = opts$ylab %||% y_col,
      labels   = if (nzchar(value_suffix))
        function(x) paste0(x, value_suffix)
      else
        ggplot2::waiver()
    ) +
    ggplot2::labs(
      title    = opts$title    %||% "",
      subtitle = opts$subtitle %||% "",
      caption  = opts$caption  %||% ""
    ) +
    ggplot2::theme_void() +
    ggplot2::theme(
      plot.title      = ggplot2::element_text(hjust = 0,
                                              face = "bold",
                                              size = 13),
      plot.subtitle   = ggplot2::element_text(hjust = 0,
                                              size = 10,
                                              colour = "#57606a"),
      legend.position = "right"
    )

  # Return via the ggplot inheritance check in the engine
  # (inherits(layers, "ggplot") -> return directly with gt$theme applied)
  p
}


# =============================================================================
# Public constructor
# =============================================================================

#' Map (Choropleth) Layer for hd Objects
#'
#' Creates a choropleth map layer for use with [hd()] and `+`.
#' Fetches GeoJSON from `map_url` and joins it to `spec$data` using the
#' column specified in `spec$x` (the join-key column) and colours regions
#' by `spec$y` (the value column).
#'
#' @section Color resolution:
#' Two-color sequential gradient for the choropleth fill:
#' \enumerate{
#'   \item Explicit `low_col` / `high_col` arguments
#'   \item `opts$colors` as a 2-element vector (first = low, second = high)
#'   \item Built-in highdir brand defaults: `"#C6DBEF"` (light) to
#'     `"#025169"` (dark teal)
#' }
#'
#' @section Norway convenience:
#' Use [hd_map_no()] to get the standard URL for Norwegian municipality
#' or county maps from the Highcharts map collection without memorising
#' the raw GitHub URL.
#'
#' @param map_url      Character. **Required.** URL of a GeoJSON file.
#'   See [hd_map_no()] for Norway maps.
#' @param join_by      Character. Property name in the GeoJSON features used
#'   to join to `spec$x`.  Default `"hc-key"` (standard for Highcharts
#'   map collections).
#' @param series_name  Character. Series label in the legend / tooltip.
#'   Defaults to `opts$ylab` or `spec$y`.
#' @param value_suffix Character. Suffix appended to values in tooltips and
#'   legend labels.  E.g. `"%"`.  Default `""`.
#' @param low_col      Character. Hex colour for the low end of the gradient.
#'   Default: `"#C6DBEF"`.
#' @param high_col     Character. Hex colour for the high end of the gradient.
#'   Default: `"#025169"`.
#' @param tooltip_fmt  Character. Highcharts tooltip `pointFormat` string.
#'   Default `"{point.name}: {point.value}"`.
#' @param nav_enabled  Logical. Enable map pan/zoom controls.  Default `TRUE`.
#'   Highcharter only.
#' @param ...          Additional arguments forwarded to [hd_make()].
#'
#' @return An S3 object of class `"hd_geom"` for use with `+.hd`.
#'
#' @seealso [hd_map_no()], [hd()], [hd_spec()], [hd_opts()]
#'
#' @examples
#' \donttest{
#' library(data.table)
#'
#' # Norwegian municipality data
#' set.seed(42)
#' url <- hd_map_no("municipality")
#'
#' # Fetch the keys from the GeoJSON so we can build a matching data frame
#' geojson  <- jsonlite::fromJSON(url, simplifyVector = FALSE)
#' features <- Filter(\(x) x$geometry$type %in%
#'   c("Polygon", "MultiPolygon"), geojson$features)
#'
#' df <- data.frame(
#'   `hc-key` = sapply(features, \(x) x$properties$`hc-key`),
#'   name     = sapply(features, \(x) x$properties$name %||% NA_character_),
#'   value    = round(runif(length(features), 10, 100), 1),
#'   check.names = FALSE
#' )
#'
#' # Dynamic mode
#' hd(df, x = "hc-key", y = "value", mode = "dynamic") +
#'   hd_geom_map(map_url = url) +
#'   hd_opts(title = "Norway", subtitle = "Random metric")
#'
#' # Custom colours
#' hd(df, x = "hc-key", y = "value", mode = "dynamic") +
#'   hd_geom_map(map_url = url, low_col = "#FFEDA0", high_col = "#E31A1C") +
#'   hd_opts(title = "Custom palette")
#'
#' # Static mode (requires sf)
#' hd(df, x = "hc-key", y = "value", mode = "static") +
#'   hd_geom_map(map_url = url) +
#'   hd_opts(title = "Static map")
#' }
#'
#' @export
hd_geom_map <- function(map_url,
                        join_by      = "hc-key",
                        series_name  = NULL,
                        value_suffix = "",
                        low_col      = NULL,
                        high_col     = NULL,
                        tooltip_fmt  = NULL,
                        nav_enabled  = TRUE,
                        ...) {

  if (missing(map_url) || is.null(map_url) || !nzchar(map_url))
    stop("hd_geom_map() requires `map_url`. See hd_map_no() for Norway maps.",
         call. = FALSE)

  hd_geom(
    "map",
    map_url      = map_url,
    join_by      = join_by,
    series_name  = series_name,
    value_suffix = value_suffix,
    low_col      = low_col,
    high_col     = high_col,
    tooltip_fmt  = tooltip_fmt,
    nav_enabled  = nav_enabled,
    ...
  )
}


# =============================================================================
# Norway map URL helper
# =============================================================================

#' Get the GeoJSON URL for Norwegian Maps
#'
#' Returns the URL of a GeoJSON file from the Highcharts map collection for
#' Norway at municipality or county level.  Pass the result directly to
#' `map_url` in [hd_geom_map()].
#'
#' @param level Character. One of:
#'   \describe{
#'     \item{`"municipality"`}{All Norwegian municipalities (default).}
#'     \item{`"county"`}{All Norwegian counties (fylker).}
#'   }
#'
#' @return A character string (URL).
#'
#' @examples
#' hd_map_no()                  # municipality URL
#' hd_map_no("county")          # county URL
#'
#' @export
hd_map_no <- function(level = c("municipality", "county")) {

  level <- match.arg(level)

  base <- paste0(
    "https://raw.githubusercontent.com/highcharts/",
    "map-collection-dist/refs/heads/master/countries/no/"
  )

  switch(level,
    municipality = paste0(base, "no-all-all.geo.json"),
    county       = paste0(base, "no-all.geo.json")
  )
}
