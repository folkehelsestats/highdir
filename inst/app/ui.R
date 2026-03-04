# inst/app/ui.R ── highdir Shiny app UI

.sidebar_controls <- shiny::tagList(

  shiny::fileInput("file", "Upload dataset",
                   accept = c(".csv", ".xlsx", ".xls",
                              ".rds", ".sav", ".dta", ".json")),

  shiny::selectInput("geom",    "Geometry",
                     choices  = list_geoms(),
                     selected = "column"),

  shiny::selectInput("backend", "Backend",
                     choices  = list_backends(),
                     selected = "highcharter"),

  # Dynamic axis mapping (populated after upload)
  shiny::uiOutput("ui_mapping"),

  # Dynamic required-arg inputs (e.g. ymin/ymax for arearange)
  shiny::uiOutput("ui_required"),

  shiny::tags$hr(),

  # Labels
  shiny::textInput("title",    "Title",    placeholder = "Optional"),
  shiny::textInput("subtitle", "Subtitle", placeholder = "Optional"),
  shiny::textInput("caption",  "Caption",  placeholder = "Optional"),

  shiny::tags$hr(),

  # Style
  shiny::conditionalPanel(
    "input.backend == 'highcharter'",
    shiny::selectInput("hc_theme", "Highcharts theme",
                       choices  = c("default","smpl","economist","darkunica",
                                    "gridlight","bloom","flat","flatdark",
                                    "ggplot2"),
                       selected = "default")
  ),
  shiny::textInput("colors", "Colours (comma-sep hex)",
                   placeholder = "#025169, #7C145C, ..."),

  shiny::tags$hr(),

  # Line options
  shiny::conditionalPanel(
    "input.geom == 'line'",
    shiny::checkboxInput("smooth",   "Smooth spline", value = TRUE),
    shiny::numericInput("dot_size", "Dot size (px)",
                        value = 4, min = 1, max = 20)
  ),

  # Pie / donut option
  shiny::conditionalPanel(
    "input.geom == 'pie'",
    shiny::textInput("inner_size", "Inner radius (donut)",
                     value = "0%", placeholder = "e.g. 50%")
  ),

  # Map options
  shiny::conditionalPanel(
    "input.geom == 'map'",
    shiny::selectInput("map_level", "Map level",
                       choices  = c("County" = "county",
                                    "Municipality" = "municipality"),
                       selected = "county"),
    shiny::textInput("map_value_lab", "Scale label",
                     placeholder = "e.g. Rate per 100 000"),
    shiny::textInput("map_low_col",  "Low colour",  value = "#C6DBEF"),
    shiny::textInput("map_high_col", "High colour", value = "#025169"),
    shiny::textInput("map_na_fill",  "NA fill",     value = "#D3D3D3")
  ),


  # JS hover band
  shiny::conditionalPanel(
    "input.backend == 'highcharter'",
    shiny::checkboxInput("use_js", "Enable JS hover band", value = TRUE)
  ),

  shiny::tags$hr(),

  shiny::actionButton("run", "Draw",
                       icon  = shiny::icon("chart-bar"),
                       class = "btn-primary"),

  shiny::br(), shiny::br(),

  shiny::textInput("dl_filename", "Download filename (no extension)",
                   placeholder = paste0("highdir-figure_", Sys.Date())),

  shiny::uiOutput("ui_downloads")
)

.main_tabs <- shiny::tabsetPanel(

  shiny::tabPanel("Figure", shiny::br(),
    shiny::conditionalPanel(
      "input.backend == 'highcharter'",
      highcharter::highchartOutput("hc_out", height = "460px")
    ),
    shiny::conditionalPanel(
      "input.backend == 'ggplot2'",
      shiny::plotOutput("gg_out", height = "460px")
    )
  ),

  shiny::tabPanel("Data preview", shiny::br(),
    shiny::tableOutput("tbl_head")),

  shiny::tabPanel("R code", shiny::br(),
    shiny::verbatimTextOutput("code_preview"))
)

ui <- if (.has_bslib) {
  bslib::page_sidebar(
    title   = "highdir \u2014 Figure Builder",
    sidebar = bslib::sidebar(.sidebar_controls, width = 320),
    .main_tabs
  )
} else {
  shiny::fluidPage(
    shiny::titlePanel("highdir \u2014 Figure Builder"),
    shiny::sidebarLayout(
      shiny::sidebarPanel(.sidebar_controls, width = 3),
      shiny::mainPanel(.main_tabs)
    )
  )
}
