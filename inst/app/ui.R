# inst/app/ui.R
# ── highdir Shiny app — UI ────────────────────────────────────────────────────
#
# Layout: sidebarLayout (sidebar 30% / main 70%)
#
# Sidebar zones:
#   1. Title + logo             always visible
#   2. File upload              always visible
#   3. Geometry + Backend       always visible
#   4. [Spec ▾] collapsible     variable mapping  — from mod_data_ui()
#   5. [Opts ▾] collapsible     labels & style    — from mod_opts_ui()
#   6. Geom options             always visible (conditionalPanel per geom)
#   7. Draw button              always visible
#   8. Download filename        always visible
#
# CSS and JS are in inst/app/www/ and loaded via tags$head().
# Shiny serves every file in www/ automatically at the root URL path,
# so "styles.css" → href="styles.css" and "app.js" → src="app.js".

# ── Head assets ───────────────────────────────────────────────────────────────

.head_assets <- shiny::tags$head(
  shiny::tags$meta(charset = "utf-8"),

  # Google Fonts — declared first so the browser starts fetching the font
  # before it even downloads styles.css.  Using <link> (not @import) is
  # faster because @import blocks CSS parsing until the font is loaded.
  shiny::tags$link(
    rel  = "preconnect",
    href = "https://fonts.googleapis.com"
  ),
  shiny::tags$link(
    rel         = "stylesheet",
    href        = "https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;600&family=IBM+Plex+Sans:wght@300;400;500;600&display=swap",
    crossorigin = NA
  ),

  # App stylesheet — served from inst/app/www/styles.css
  shiny::tags$link(rel = "stylesheet", href = "styles.css"),

  # App JS — served from inst/app/www/app.js
  # Placed in <head> with defer so it does not block page render,
  # and jQuery (loaded by Shiny) is guaranteed to be available when it runs.
  shiny::tags$script(defer = NA, src = "app.js")
)

# ── Sidebar ───────────────────────────────────────────────────────────────────

.sidebar <- shiny::div(

  # Title + logo
  shiny::div(
    style = "display:flex; align-items:center; justify-content:space-between;",
    shiny::div(
      shiny::div(class = "hd-title",   "highdir"),
      shiny::div(class = "hd-tagline", "Create Figure")
    ),
    shiny::img(src = "logo.png", height = "60px",
               style = "margin-left:6px;", id = "app_logo")
  ),

  # Geometry + Backend — always visible, populated from the registry
  shiny::div(class = "hd-label", "Figure"),
  shiny::selectInput("geom",    NULL, choices = list_geoms(),    selected = "column"),
  shiny::selectInput("backend", NULL, choices = list_backends(), selected = "highcharter"),

  # Spec collapsible — mod_data_ui() owns file upload + column mapping
  mod_data_ui("data"),

  # Opts collapsible — mod_opts_ui() owns labels, style, downloads
  mod_opts_ui("opts"),

  # ── Geom-specific options (always visible, client-side show/hide) ─────────
  shiny::div(class = "hd-label", "Geom options"),

  shiny::conditionalPanel(
    condition = "input.geom == 'ranked_bar'",
    shiny::checkboxInput("ascending", "Ascending order", value = TRUE),
    shiny::textInput("comp", NULL, placeholder = "Highlight group (e.g. Oslo)"),
    shiny::numericInput("aim", "Aim line", value = NA, min = 0)
  ),

  shiny::conditionalPanel(
    condition = "input.geom == 'line'",
    shiny::checkboxInput("smooth",   "Smooth spline", value = TRUE),
    shiny::numericInput("dot_size", "Dot size (px)", value = 4, min = 1, max = 20)
  ),

  shiny::conditionalPanel(
    condition = "input.geom == 'pie'",
    shiny::textInput("inner_size", "Inner radius",
                     value = "0%", placeholder = "e.g. 50%")
  ),

  shiny::conditionalPanel(
    condition = "input.geom == 'map'",
    shiny::selectInput("map_level", "Level",
                       choices  = c("County" = "county", "Municipality" = "municipality"),
                       selected = "county"),
    shiny::textInput("map_value_lab", "Scale label",   placeholder = "Rate per 100 000"),
    shiny::textInput("map_low_col",   "Low colour",    value = "#C6DBEF"),
    shiny::textInput("map_high_col",  "High colour",   value = "#025169"),
    shiny::textInput("map_na_fill",   "NA fill",       value = "#D3D3D3")
  ),

  shiny::conditionalPanel(
    condition = "input.geom == 'column' || input.geom == 'scatter' || input.geom == 'arearange'",
    shiny::tags$p(
      style = "font-size:11px; color:#8b949e; margin:2px 0 0;",
      "No extra options for this geometry."
    )
  ),

  # Draw button — full width, always visible
  shiny::actionButton("run", "Draw figure",
                      icon  = shiny::icon("palette"),
                      class = "btn-primary")
)

# ── Root UI ───────────────────────────────────────────────────────────────────

ui <- shiny::fluidPage(
  .head_assets,
  shiny::sidebarLayout(
    shiny::sidebarPanel(.sidebar,          width = 3),
    shiny::mainPanel(mod_figure_ui("fig"), width = 9)
  )
)
