# R/geom-map.R ── Norway choropleth map geometry
#
# Two backends:
#
#   gg_map  — static sf / ggplot2 choropleth.
#             Geometry: downloads Highcharts TopoJSON the first time, caches
#             it in the session via .norway_sf_cache.  Requires {sf}.
#
#   hc_map  — interactive Highcharter / Highmaps choropleth.
#             Uses highcharter::hcmap() which loads TopoJSON from the
#             Highcharts CDN at render time (browser does the fetch).
#
# ── Data contract ─────────────────────────────────────────────────────────────
#
#   spec$x  → column with region identifiers.  Accepts:
#               - 2-digit county code as integer/character   ("03", 3)
#               - 4-digit municipality code                  ("0301", 301)
#               - Full Highcharts hc-key                     ("no-03", "no-0301")
#             Codes are auto-detected and zero-padded.
#   spec$y  → column with numeric fill values
#   spec$group → ignored (maps are single-series)
#
# geom_params from hd_make():
#   level      "county" (default) | "municipality"
#   value_lab  Legend / scale title.  Defaults to spec$ylab.
#   na_fill    Colour for missing regions.      Default "#D3D3D3"
#   low_col    Low-end choropleth colour.       Default "#C6DBEF"
#   high_col   High-end choropleth colour.      Default "#025169"

# ── Session geometry cache (avoids repeated downloads) ────────────────────────

#' @keywords internal
.norway_sf_cache <- new.env(parent = emptyenv())

# ── Region-code normalisation ─────────────────────────────────────────────────

#' Convert any supported Norway region code to a zero-padded string
#'
#' Accepts integers (301), numerics (301.0), or character ("0301", "no-0301").
#' Strips any "no-XX-" or "no-" prefix and zero-pads to the required width.
#'
#' @param codes  Vector of region codes (integer, numeric, or character).
#' @param level  `"county"` (width 2) or `"municipality"` (width 4).
#' @return Character vector of zero-padded codes, e.g. "0301", "03".
#' @keywords internal
.norm_code <- function(codes, level = c("county", "municipality")) {
  level <- match.arg(level)
  w     <- if (level == "county") 2L else 4L
  s     <- as.character(codes)
  # strip any leading "no-XX-" (municipality HC key) or "no-" (county HC key)
  s     <- sub("^no-[0-9]{2}-", "", s)
  s     <- sub("^no-",          "", s)
  formatC(trimws(s), width = w, flag = "0")
}

#' Convert region codes to Highcharts hc-key format
#'
#' @param codes  Vector of region codes.
#' @param level  `"county"` or `"municipality"`.
#' @return Character vector like `"no-03"`, `"no-03-0301"`.
#' @keywords internal
.to_hc_key <- function(codes, level = c("county", "municipality")) {
  level  <- match.arg(level)
  padded <- .norm_code(codes, level)
  if (level == "county")
    return(paste0("no-", padded))
  # Highcharts municipality key: "no-<county2>-<kommune4>"
  county <- substr(padded, 1, 2)
  paste0("no-", county, "-", padded)
}

# ── ggplot2 map geom ──────────────────────────────────────────────────────────

#' @keywords internal
gg_map <- function(spec, opts, geom_params, ...) {

  if (!requireNamespace("sf", quietly = TRUE))
    stop("The 'sf' package is required for gg_map().\n",
         "Install it with: install.packages('sf')", call. = FALSE)

  level     <- geom_params$level     %||% "county"
  value_lab <- geom_params$value_lab %||% spec$ylab
  na_fill   <- geom_params$na_fill   %||% "#D3D3D3"
  low_col   <- geom_params$low_col   %||% "#C6DBEF"
  high_col  <- geom_params$high_col  %||% "#025169"

  # Get Norway sf shapes (cached after first download)
  norway_sf <- .get_norway_sf(level)

  # Build join key from user's region codes
  df          <- spec$data
  df$.hc_key  <- .to_hc_key(df[[spec$x]], level)

  # Merge: all map shapes kept (all.x=TRUE) so unmapped regions show na_fill
  merged <- merge(norway_sf, df[, c(".hc_key", spec$y), drop = FALSE],
                  by.x = "hc_key", by.y = ".hc_key", all.x = TRUE)

  list(
    ggplot2::geom_sf(
      data      = merged,
      mapping   = ggplot2::aes(fill = .data[[spec$y]]),
      colour    = "white",
      linewidth = 0.25
    ),
    ggplot2::scale_fill_gradient(
      name     = value_lab,
      low      = low_col,
      high     = high_col,
      na.value = na_fill,
      guide    = ggplot2::guide_colorbar(
        title.position = "top",
        barwidth       = ggplot2::unit(0.4, "cm"),
        barheight      = ggplot2::unit(4,   "cm")
      )
    ),
    ggplot2::coord_sf(datum = NA),
    ggplot2::theme_void(),
    ggplot2::theme(
      legend.position = "right",
      legend.title    = ggplot2::element_text(size = 9),
      legend.text     = ggplot2::element_text(size = 8),
      plot.title      = ggplot2::element_text(
        size = 13, face = "bold",
        margin = ggplot2::margin(b = 4)
      ),
      plot.subtitle   = ggplot2::element_text(
        size = 10, colour = "#555555",
        margin = ggplot2::margin(b = 8)
      ),
      plot.caption    = ggplot2::element_text(
        size = 8, colour = "#888888",
        margin = ggplot2::margin(t = 6)
      )
    )
  )
}

# ── highcharter map geom ──────────────────────────────────────────────────────

#' @keywords internal
hc_map <- function(chart_ignored, spec, opts, geom_params,
                   use_js = TRUE, ...) {

  level     <- geom_params$level     %||% "county"
  value_lab <- geom_params$value_lab %||% spec$ylab
  na_fill   <- geom_params$na_fill   %||% "#D3D3D3"
  low_col   <- geom_params$low_col   %||% "#C6DBEF"
  high_col  <- geom_params$high_col  %||% "#025169"

  # Highcharts map topology key (loaded from CDN by the browser)
  map_key <- if (level == "county") "countries/no/no-all"
             else                    "countries/no/no-all-all"

  # Build join data frame: hc-key + value + display name
  df          <- spec$data
  hc_keys     <- .to_hc_key(df[[spec$x]], level)

  # Look up display names for tooltip
  lookup  <- if (level == "county") no_counties() else no_municipalities()
  padded  <- .norm_code(df[[spec$x]], level)
  id_col  <- if (level == "county") "fylkesnummer" else "kommunenummer"
  matched <- lookup$name[match(padded, lookup[[id_col]])]
  disp    <- ifelse(is.na(matched), padded, matched)

  map_df  <- data.frame(
    "hc-key"   = hc_keys,
    value      = df[[spec$y]],
    region     = disp,
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
  if (!is.null(spec$n)) map_df$n_obs <- df[[spec$n]]

  # Tooltip format
  tt_extra <- if (!is.null(spec$n))
    paste0("<br/>n\u00a0=\u00a0{point.n_obs}")
  else ""

  tooltip_fmt <- paste0(
    "<b>{point.region}</b><br/>",
    value_lab, ":\u00a0<b>{point.value}</b>", tt_extra
  )

  # Build the Highmaps widget from scratch (no generic base_fig canvas)
  mc <- highcharter::highchart(type = "map")

  if (!is.null(opts$title))
    mc <- mc |> highcharter::hc_title(
      text  = opts$title,
      style = list(fontSize = "16px", fontWeight = "bold")
    )

  mc <- mc |>
    highcharter::hc_subtitle(
      text = opts$subtitle %||% "Kilde: Navn av kilder"
    ) |>
    highcharter::hc_colorAxis(
      minColor = low_col,
      maxColor = high_col,
      nullColor = na_fill
    ) |>
    highcharter::hc_legend(
      enabled       = TRUE,
      layout        = "vertical",
      align         = "right",
      verticalAlign = "middle",
      title         = list(text = value_lab)
    ) |>
    highcharter::hc_tooltip(
      useHTML     = TRUE,
      headerFormat = "",
      pointFormat  = tooltip_fmt
    ) |>
    highcharter::hc_mapNavigation(
      enabled              = TRUE,
      enableMouseWheelZoom = TRUE,
      buttonOptions        = list(verticalAlign = "bottom")
    ) |>
    highcharter::hc_credits(
      enabled = TRUE,
      text    = "Helsedirektoratet",
      href    = "https://www.helsedirektoratet.no/"
    ) |>
    highcharter::hc_exporting(
      enabled  = TRUE,
      filename = "highdir-kart",
      accessibility = list(enabled = TRUE)
    ) |>
    highcharter::hc_add_dependency("modules/accessibility.js") |>
    highcharter::hc_add_series_map(
      map        = map_key,
      df         = map_df,
      joinBy     = "hc-key",
      value      = "value",
      name       = value_lab,
      borderColor = "white",
      borderWidth = 0.5,
      nullColor   = na_fill,
      dataLabels  = list(enabled = FALSE)
    )

  if (!is.null(opts$caption))
    mc <- mc |> highcharter::hc_caption(text = opts$caption)

  mc
}

# ── sf download + session cache ───────────────────────────────────────────────

#' Get Norway sf geometry (download once, then cache)
#' @keywords internal
.get_norway_sf <- function(level = c("county", "municipality")) {
  level    <- match.arg(level)
  cache_id <- paste0("norway_", level)

  if (exists(cache_id, envir = .norway_sf_cache))
    return(.norway_sf_cache[[cache_id]])

  result <- tryCatch(
    .download_norway_sf(level),
    error = function(e) {
      message("[highdir] Could not download Norway TopoJSON: ",
              conditionMessage(e),
              "\nFalling back to 'maps' package (low resolution, counties only).")
      .fallback_norway_sf()
    }
  )

  .norway_sf_cache[[cache_id]] <- result
  result
}

#' Download Norway TopoJSON from Highcharts CDN and return as sf
#' @keywords internal
.download_norway_sf <- function(level) {
  base <- "https://code.highcharts.com/mapdata/countries/no/"
  url  <- if (level == "county")
    paste0(base, "no-all.topo.json")
  else
    paste0(base, "no-all-all.topo.json")

  tmp <- tempfile(fileext = ".json")
  on.exit(unlink(tmp), add = TRUE)
  utils::download.file(url, tmp, quiet = TRUE, mode = "wb")

  layers <- sf::st_layers(tmp)$name
  geo    <- sf::st_read(tmp,
                         layer = if (length(layers)) layers[1] else NULL,
                         quiet = TRUE)
  nms <- names(geo)

  # Normalise the key column name
  if ("hc-key" %in% nms) {
    names(geo)[names(geo) == "hc-key"] <- "hc_key"
  } else if (!"hc_key" %in% nms) {
    # Try common alternatives from different TopoJSON versions
    alt <- intersect(c("code", "id", "HASC_1", "iso-a2"), nms)
    if (length(alt))
      names(geo)[names(geo) == alt[1]] <- "hc_key"
    else
      stop("Cannot identify the region-key column in the downloaded TopoJSON.")
  }

  # Keep only hc_key + geometry
  geom_col <- attr(geo, "sf_column")
  geo[, c("hc_key", geom_col), drop = FALSE]
}

#' Fallback Norway sf from the {maps} package (county-level only)
#' @keywords internal
.fallback_norway_sf <- function() {
  if (!requireNamespace("maps", quietly = TRUE))
    stop("No internet and 'maps' package is not installed.\n",
         "Install: install.packages('maps')", call. = FALSE)

  world   <- maps::map("world", "Norway", fill = TRUE, plot = FALSE)
  sf_obj  <- sf::st_as_sf(world) |>
               sf::st_make_valid()
  # Attach placeholder hc_keys
  ref            <- no_counties()
  sf_obj$hc_key  <- rep(ref$hc_key, length.out = nrow(sf_obj))
  sf_obj
}

# ── Public reference tables ───────────────────────────────────────────────────

#' Norway County Reference Table
#'
#' Returns a data frame of the 15 Norwegian counties (fylker) with official
#' SSB `fylkesnummer`, Norwegian names, and the Highcharts `hc_key` values
#' used to join data to the `"countries/no/no-all"` map topology.
#'
#' Use this to prepare your data for `hd_make(..., type = "map", level = "county")`:
#'
#' ```r
#' library(dplyr)
#' my_data %>%
#'   left_join(no_counties(), by = "fylkesnummer") %>%
#'   hd_spec(x = "fylkesnummer", y = "rate") %>%
#'   hd_make("map", level = "county")
#' ```
#'
#' @return A `data.frame` with columns:
#' \describe{
#'   \item{fylkesnummer}{Character. 2-digit SSB code, e.g. `"03"`.}
#'   \item{name}{Character. Norwegian county name.}
#'   \item{hc_key}{Character. Highcharts join key, e.g. `"no-03"`.}
#' }
#' @export
#' @examples
#' no_counties()
no_counties <- function() {
  data.frame(
    fylkesnummer = c("03","11","15","18","30","34","38",
                     "42","46","50","54","55","56","57","58"),
    name         = c("Oslo","Rogaland","Møre og Romsdal","Nordland",
                     "Viken","Innlandet","Vestfold og Telemark",
                     "Agder","Vestland","Trøndelag","Troms og Finnmark",
                     "Jan Mayen","Svalbard","Bouvetøya","Peter I\u2019s \u00f8y"),
    hc_key       = c("no-03","no-11","no-15","no-18","no-30","no-34","no-38",
                     "no-42","no-46","no-50","no-54","no-55","no-56","no-57","no-58"),
    stringsAsFactors = FALSE
  )
}

#' Norway Municipality Reference Table
#'
#' Returns a data frame of Norwegian municipalities (kommuner) with SSB
#' `kommunenummer`, names, Highcharts `hc_key` values for the
#' `"countries/no/no-all-all"` topology, and parent `fylkesnummer`.
#'
#' @return A `data.frame` with columns:
#' \describe{
#'   \item{kommunenummer}{Character. 4-digit SSB code, e.g. `"0301"`.}
#'   \item{name}{Character. Municipality name.}
#'   \item{hc_key}{Character. Highcharts join key, e.g. `"no-03-0301"`.}
#'   \item{fylkesnummer}{Character. Parent county 2-digit code.}
#' }
#' @export
#' @examples
#' head(no_municipalities())
#' subset(no_municipalities(), fylkesnummer == "46")  # Vestland
no_municipalities <- function() {
  # Representative set covering all counties.  For the complete SSB list
  # use: utils::read.csv(
  #   "https://data.ssb.no/api/klass/v1/classifications/131/codesAt.csv?date=2024-01-01"
  # )
  raw <- list(
    # Oslo
    list("0301","Oslo",          "03"),
    # Rogaland
    list("1103","Stavanger",     "11"),
    list("1106","Haugesund",     "11"),
    list("1108","Sandnes",       "11"),
    list("1149","Karmøy",        "11"),
    # Møre og Romsdal
    list("1505","Kristiansund",  "15"),
    list("1506","Molde",         "15"),
    list("1507","Ålesund",       "15"),
    # Nordland
    list("1804","Bodø",          "18"),
    list("1806","Narvik",        "18"),
    list("1833","Rana",          "18"),
    # Viken
    list("3005","Drammen",       "30"),
    list("3024","Bærum",         "30"),
    list("3025","Asker",         "30"),
    list("3030","Lillestrøm",    "30"),
    # Innlandet
    list("3403","Hamar",         "34"),
    list("3405","Lillehammer",   "34"),
    list("3407","Gjøvik",        "34"),
    # Vestfold og Telemark
    list("3803","Tønsberg",      "38"),
    list("3804","Sandefjord",    "38"),
    list("3806","Porsgrunn",     "38"),
    list("3807","Skien",         "38"),
    # Agder
    list("4203","Arendal",       "42"),
    list("4204","Kristiansand",  "42"),
    list("4205","Lindesnes",     "42"),
    # Vestland
    list("4601","Bergen",        "46"),
    list("4615","Øygarden",      "46"),
    list("4616","Askøy",         "46"),
    # Trøndelag
    list("5001","Trondheim",     "50"),
    list("5006","Steinkjer",     "50"),
    list("5007","Namsos",        "50"),
    list("5024","Levanger",      "50"),
    list("5025","Verdal",        "50"),
    # Troms og Finnmark
    list("5401","Tromsø",        "54"),
    list("5402","Harstad",       "54"),
    list("5403","Alta",          "54"),
    list("5406","Hammerfest",    "54")
  )

  kommunenummer <- vapply(raw, `[[`, character(1), 1L)
  name          <- vapply(raw, `[[`, character(1), 2L)
  fylkesnummer  <- vapply(raw, `[[`, character(1), 3L)

  data.frame(
    kommunenummer = kommunenummer,
    name          = name,
    hc_key        = paste0("no-", fylkesnummer, "-", kommunenummer),
    fylkesnummer  = fylkesnummer,
    stringsAsFactors = FALSE
  )
}
