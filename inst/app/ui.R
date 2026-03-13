# inst/app/ui.R
# ── highdir Shiny app — UI ────────────────────────────────────────────────────
#
# Sidebar zones (top → bottom):
#   1. Title + logo             always visible
#   2. Geometry + Backend       always visible
#   3. [Spec ▾] collapsible     file upload + variable mapping
#   4. [Opts ▾] collapsible     labels & style
#   5. Geom options             renderUI — driven by input$geom (server-side)
#   6. Draw button              always visible
#   7. Download buttons         always visible (static, conditionalPanel)
#
# Download buttons are STATIC in the UI (not inside renderUI) so they appear
# immediately and their IDs are unambiguous — no module namespace issues.
# Handlers are registered directly in server.R.

# ── Head assets ───────────────────────────────────────────────────────────────

.head_assets <- shiny::tags$head(
  shiny::tags$meta(charset = "utf-8"),
  shiny::tags$link(rel = "preconnect", href = "https://fonts.googleapis.com"),
  shiny::tags$link(
    rel  = "stylesheet",
    href = "https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;600&family=IBM+Plex+Sans:wght@300;400;500;600&display=swap"
  ),
  shiny::tags$link(rel = "stylesheet", href = "styles.css"),
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
    shiny::img(src = "logo.png", height = "80px",
               style = "margin-left:6px;", id = "app_logo")
  ),

  # Geometry + Backend
  shiny::div(class = "hd-label", "Figure"),
  shiny::selectInput("geom",    NULL, choices = list_geoms(),    selected = "column"),
  shiny::selectInput("backend", NULL, choices = list_backends(), selected = "highcharter"),

  # Spec collapsible — file upload + column mapping
  mod_data_ui("data"),

  # Opts collapsible — labels, style
  mod_opts_ui("opts"),

  # ── Geom options (dynamic — rendered from registry in server.R) ──────────
  # uiOutput here is intentional: the number and type of inputs varies
  # entirely by geometry.  The server reads optional_args from the registry
  # and builds the appropriate inputs.  This replaces the previous
  # hard-coded conditionalPanel blocks which were incomplete.
  shiny::div(class = "hd-label", "Geom options"),
  shiny::uiOutput("ui_geom_opts"),

  # ── Draw button ───────────────────────────────────────────────────────────
  shiny::actionButton("run", "Draw figure",
                      icon  = shiny::icon("palette"),
                      class = "btn-primary"),

  # ── Download buttons — STATIC, always in DOM ──────────────────────────────
  # Placing these here (not inside renderUI or a module) means:
  #   • They appear immediately — no server round-trip, no delay
  #   • Their IDs ("dl_json", "dl_html", etc.) are top-level — handlers
  #     registered as output$dl_json in server.R match without namespace issues
  #   • conditionalPanel hides/shows client-side — zero server cost
  #
  # Buttons are disabled via CSS class "disabled" until a figure exists;
  # server.R removes the class via shinyjs or we rely on downloadHandler's
  # own guard (req()) — the button is always clickable but produces nothing
  # until a figure has been drawn.
  shiny::div(class = "hd-label", "Download"),
  shiny::textInput("dl_filename", NULL,
                   placeholder = paste0("highdir-figure_", Sys.Date())),
  shiny::div(
    class = "hd-dl-row",
    # HC buttons — shown when backend == highcharter
    shiny::conditionalPanel(
      condition = "input.backend == 'highcharter'",
      shiny::downloadButton("dl_json", "JSON"),
      shiny::downloadButton("dl_html", "HTML")
    ),
    # ggplot2 buttons — shown when backend == ggplot2
    shiny::conditionalPanel(
      condition = "input.backend == 'ggplot2'",
      shiny::downloadButton("dl_gg_png", "PNG"),
      shiny::downloadButton("dl_gg_svg", "SVG")
    )
  )
)

# ── Root UI ───────────────────────────────────────────────────────────────────

ui <- shiny::fluidPage(
  .head_assets,
  shiny::sidebarLayout(
    shiny::sidebarPanel(.sidebar,          width = 3),
    shiny::mainPanel(mod_figure_ui("fig"), width = 9)
  )
)
