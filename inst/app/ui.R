# inst/app/ui.R ── highdir Shiny app UI
#
# Layout: standard sidebarLayout (sidebar ~30%, main ~70%)
#
# Sidebar structure:
#   Always visible:
#     - File upload
#     - Geometry + Backend
#     - Geom-specific args (ranked_bar / line / pie / map)
#     - Draw button
#   Collapsible (toggle buttons, hidden by default):
#     [Spec ▾]  → variable mapping + required args
#     [Opts ▾]  → labels, style, download

# ── CSS ───────────────────────────────────────────────────────────────────────

.app_css <- shiny::tags$style(shiny::HTML("

  @import url('https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;600&family=IBM+Plex+Sans:wght@300;400;500;600&display=swap');

  body {
    font-family: 'IBM Plex Sans', sans-serif;
    font-size: 13px;
    background: #f4f5f7;
    color: #1a1d23;
  }

  /* ── Sidebar panel ─────────────────────────────────────── */
  .well {
    background: #ffffff !important;
    border: none !important;
    border-right: 1px solid #e1e8ed !important;
    border-radius: 0 !important;
    box-shadow: none !important;
    padding: 14px 14px 20px !important;
    min-height: 100vh;
  }

  /* ── App title ──────────────────────────────────────────── */
  .hd-title {
    font-family: 'IBM Plex Mono', monospace;
    font-size: 15px;
    font-weight: 600;
    color: #025169;
    letter-spacing: -0.3px;
    margin-bottom: 2px;
  }
  .hd-tagline {
    font-size: 10.5px;
    color: #8b949e;
    font-weight: 300;
    margin-bottom: 14px;
  }

  /* ── Section label (always-visible group headers) ────────── */
  .hd-label {
    font-family: 'IBM Plex Mono', monospace;
    font-size: 9.5px;
    font-weight: 600;
    letter-spacing: 1.1px;
    text-transform: uppercase;
    color: #025169;
    border-bottom: 1px solid #e6ebf0;
    padding-bottom: 3px;
    margin: 12px 0 7px;
  }
  .hd-label:first-of-type { margin-top: 0; }

  /* ── Collapsible toggle buttons (Spec / Opts) ────────────── */
  .hd-toggle {
    display: flex;
    align-items: center;
    justify-content: space-between;
    width: 100%;
    margin: 8px 0 0;
    padding: 5px 9px;
    background: #f6f8fa;
    border: 1px solid #d0d7de;
    border-radius: 5px;
    cursor: pointer;
    font-family: 'IBM Plex Mono', monospace;
    font-size: 10.5px;
    font-weight: 600;
    letter-spacing: 0.5px;
    text-transform: uppercase;
    color: #1a1d23;
    transition: background 0.12s, border-color 0.12s;
    outline: none;
  }
  .hd-toggle:hover {
    background: #e8f4f8;
    border-color: #025169;
    color: #025169;
  }
  .hd-toggle.open {
    background: #e8f4f8;
    border-color: #025169;
    color: #025169;
  }
  .hd-toggle .hd-arrow {
    font-size: 9px;
    transition: transform 0.18s;
    display: inline-block;
  }
  .hd-toggle.open .hd-arrow {
    transform: rotate(180deg);
  }

  /* ── Collapsible body ─────────────────────────────────────── */
  .hd-collapse {
    display: none;
    background: #fafcfd;
    border: 1px solid #e1e8ed;
    border-top: none;
    border-radius: 0 0 5px 5px;
    padding: 10px 10px 6px;
    margin-bottom: 4px;
  }
  .hd-collapse.open { display: block; }

  /* ── Form controls ────────────────────────────────────────── */
  .form-group { margin-bottom: 7px; }

  label {
    font-size: 10.5px !important;
    font-weight: 600 !important;
    color: #57606a !important;
    text-transform: uppercase !important;
    letter-spacing: 0.35px !important;
    margin-bottom: 2px !important;
  }
  .form-control {
    font-size: 12px !important;
    height: 28px !important;
    padding: 3px 8px !important;
    border: 1px solid #d0d7de !important;
    border-radius: 4px !important;
    background: #f6f8fa !important;
    transition: border-color 0.12s, box-shadow 0.12s !important;
  }
  .form-control:focus {
    border-color: #025169 !important;
    box-shadow: 0 0 0 2px rgba(2,81,105,0.1) !important;
    background: #fff !important;
    outline: none !important;
  }
  select.form-control { height: 28px !important; }
  .form-control[readonly] { color: #8b949e; }

  .checkbox label {
    text-transform: none !important;
    font-size: 12px !important;
    font-weight: 400 !important;
    color: #1a1d23 !important;
    letter-spacing: 0 !important;
  }

  /* file input button */
  .btn-file span { font-size: 11px !important; }

  /* ── Draw button ──────────────────────────────────────────── */
  #run {
    width: 100%;
    margin-top: 12px;
    font-family: 'IBM Plex Mono', monospace;
    font-size: 12px;
    font-weight: 600;
    letter-spacing: 0.6px;
    background: #025169 !important;
    border: none !important;
    color: #fff !important;
    padding: 7px 0;
    border-radius: 5px;
    cursor: pointer;
    transition: background 0.15s;
  }
  #run:hover { background: #037090 !important; }

  /* ── Download buttons ─────────────────────────────────────── */
  .hd-dl-row { display: flex; flex-wrap: wrap; gap: 4px; margin-top: 4px; }
  .hd-dl-row .btn {
    font-size: 10.5px;
    padding: 2px 8px;
    border-radius: 3px;
    border: 1px solid #d0d7de;
    background: #f6f8fa;
    color: #1a1d23;
  }
  .hd-dl-row .btn:hover { background: #e1e8ed; }

  /* ── Main output tabs ─────────────────────────────────────── */
  .nav-tabs > li > a {
    font-family: 'IBM Plex Mono', monospace;
    font-size: 10.5px;
    font-weight: 600;
    letter-spacing: 0.5px;
    text-transform: uppercase;
    color: #57606a;
    border-bottom: 3px solid transparent;
    border-radius: 0;
    padding: 7px 14px;
  }
  .nav-tabs > li.active > a,
  .nav-tabs > li > a:hover {
    color: #025169 !important;
    border-bottom: 3px solid #025169 !important;
    background: transparent !important;
    border-top: none !important;
    border-left: none !important;
    border-right: none !important;
  }
  .tab-content { padding-top: 10px; }

  /* ── Code preview ─────────────────────────────────────────── */
  pre {
    font-family: 'IBM Plex Mono', monospace;
    font-size: 12px;
    background: #0d1117;
    color: #c9d1d9;
    border: none;
    border-radius: 6px;
    padding: 14px 16px;
    line-height: 1.65;
  }

  /* ── Data table ───────────────────────────────────────────── */
  .table { font-size: 12px; }
  .table th {
    font-family: 'IBM Plex Mono', monospace;
    font-size: 10px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    color: #57606a;
    border-bottom: 2px solid #025169 !important;
  }

  /* ── Scrollbar ────────────────────────────────────────────── */
  ::-webkit-scrollbar { width: 5px; height: 5px; }
  ::-webkit-scrollbar-track { background: transparent; }
  ::-webkit-scrollbar-thumb { background: #c6cbd1; border-radius: 3px; }
  ::-webkit-scrollbar-thumb:hover { background: #8b949e; }
"))

# ── JS for collapsible panels ─────────────────────────────────────────────────

.app_js <- shiny::tags$script(shiny::HTML("
  $(document).on('click', '.hd-toggle', function() {
    var target = $(this).data('target');
    $(this).toggleClass('open');
    $(target).toggleClass('open');
  });
"))

# ── Sidebar contents ──────────────────────────────────────────────────────────

.sidebar <- shiny::div(

  # Title + Logo row
  shiny::div(
    style = "display:flex; align-items:center; justify-content:space-between;",

    shiny::div(
      shiny::div(class = "hd-title", "highdir"),
      shiny::div(class = "hd-tagline", "Create Figure")
    ),

    shiny::img(
      src = "logo.png",
      height = "60px",
      style = "margin-left:6px;",
      id = "app_logo"
    )
  ),
  # ── Always visible: Data + config ────────────────────────────
  shiny::div(class = "hd-label", "Data"),
  shiny::fileInput("file", NULL,
                   accept      = c(".csv",".xlsx",".xls",
                                   ".rds",".sav",".dta",".json"),
                   placeholder = "CSV / XLSX / RDS …",
                   buttonLabel = shiny::icon("folder-open")),

  shiny::div(class = "hd-label", "Figure"),
  shiny::selectInput("geom",    NULL,
                     choices  = list_geoms(),
                     selected = "column"),
  shiny::selectInput("backend", NULL,
                     choices  = list_backends(),
                     selected = "highcharter"),

  # ── Collapsible: Spec ─────────────────────────────────────────
  shiny::tags$button(
    class       = "hd-toggle",
    `data-target` = "#panel-spec",
    shiny::span("Spec — variable mapping"),
    shiny::span(class = "hd-arrow", "\u25bc")
  ),
  shiny::div(
    id    = "panel-spec",
    class = "hd-collapse",
    shiny::uiOutput("ui_mapping"),
    shiny::uiOutput("ui_required")
  ),

  # ── Collapsible: Opts ─────────────────────────────────────────
  shiny::tags$button(
    class         = "hd-toggle",
    `data-target` = "#panel-opts",
    shiny::span("Opts — labels & style"),
    shiny::span(class = "hd-arrow", "\u25bc")
  ),
  shiny::div(
    id    = "panel-opts",
    class = "hd-collapse",

    shiny::div(class = "hd-label", style = "margin-top:4px;", "Labels"),
    shiny::textInput("title",    NULL, placeholder = "Title"),
    shiny::textInput("subtitle", NULL, placeholder = "Subtitle"),
    shiny::textInput("caption",  NULL, placeholder = "Caption"),
    shiny::textInput("xlab",     NULL, placeholder = "X-axis label"),
    shiny::textInput("ylab",     NULL, placeholder = "Y-axis label"),

    shiny::div(class = "hd-label", "Style"),
    shiny::textInput("colors", NULL,
                     placeholder = "Colours: #025169, #7C145C, …"),
    shiny::conditionalPanel(
      "input.backend == 'highcharter'",
      shiny::selectInput("hc_theme", NULL,
                         choices  = c("default","smpl","economist",
                                      "darkunica","gridlight","bloom",
                                      "flat","flatdark","ggplot2"),
                         selected = "default"),
      shiny::checkboxInput("use_js", "JS hover band", value = TRUE)
    )
  ),

  # ── Always visible: Geom-specific args ───────────────────────
  shiny::div(class = "hd-label", "Geom options"),

  shiny::conditionalPanel(
    "input.geom == 'ranked_bar'",
    shiny::checkboxInput("ascending", "Ascending order", value = TRUE),
    shiny::textInput("comp", NULL, placeholder = "Highlight group (e.g. Oslo)"),
    shiny::numericInput("aim", "Aim line", value = NA, min = 0)
  ),

  shiny::conditionalPanel(
    "input.geom == 'line'",
    shiny::checkboxInput("smooth",   "Smooth spline", value = TRUE),
    shiny::numericInput("dot_size", "Dot size (px)",
                        value = 4, min = 1, max = 20)
  ),

  shiny::conditionalPanel(
    "input.geom == 'pie'",
    shiny::textInput("inner_size", "Inner radius",
                     value = "0%", placeholder = "e.g. 50%")
  ),

  shiny::conditionalPanel(
    "input.geom == 'map'",
    shiny::selectInput("map_level", "Level",
                       choices  = c("County"       = "county",
                                    "Municipality" = "municipality"),
                       selected = "county"),
    shiny::textInput("map_value_lab", "Scale label",
                     placeholder = "Rate per 100 000"),
    shiny::textInput("map_low_col",  "Low colour",  value = "#C6DBEF"),
    shiny::textInput("map_high_col", "High colour", value = "#025169"),
    shiny::textInput("map_na_fill",  "NA fill",     value = "#D3D3D3")
  ),

  shiny::conditionalPanel(
    "input.geom == 'column' || input.geom == 'scatter' || input.geom == 'arearange'",
    shiny::tags$p(
      style = "font-size:11px; color:#8b949e; margin:2px 0 0;",
      "No extra options for this geometry."
    )
  ),

  # ── Draw ─────────────────────────────────────────────────────
  shiny::actionButton("run", "Draw figure",
                      icon  = shiny::icon("palette"),
                      class = "btn-primary"),

  # -- Download ----
    shiny::div(class = "hd-label", "Download"),
    shiny::textInput("dl_filename", NULL,
                     placeholder = paste0("highdir-figure_", Sys.Date())),
    shiny::div(class = "hd-dl-row", shiny::uiOutput("ui_downloads"))
)

# ── Main output tabs ──────────────────────────────────────────────────────────

.main <- shiny::tabsetPanel(
  id   = "out_tabs",
  type = "tabs",

  shiny::tabPanel("Figure",
    shiny::br(),
    shiny::conditionalPanel(
      "input.backend == 'highcharter'",
      highcharter::highchartOutput("hc_out", height = "520px")
    ),
    shiny::conditionalPanel(
      "input.backend == 'ggplot2'",
      shiny::plotOutput("gg_out", height = "520px")
    )
  ),

  shiny::tabPanel("Data",
    shiny::br(),
    DT::DTOutput("tbl_head")
  ),

  shiny::tabPanel("R code",
    shiny::br(),
    shiny::verbatimTextOutput("code_preview")
  )
)

# ── Root UI ───────────────────────────────────────────────────────────────────

ui <- shiny::fluidPage(
  .app_css,
  shiny::tags$head(
    shiny::tags$meta(charset = "utf-8"),
    .app_js
  ),
  shiny::sidebarLayout(
    shiny::sidebarPanel(.sidebar, width = 3),
    shiny::mainPanel(.main,       width = 9)
  )
)
