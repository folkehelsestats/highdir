#' @keywords internal
app_ui <- function() {
  shiny::fluidPage(
    shiny::titlePanel("highdir demo"),
    shiny::sidebarLayout(
      shiny::sidebarPanel(
        shiny::fileInput("file", "Upload CSV", accept = c(".csv", ".tsv")),
        shiny::radioButtons("sep", "Separator", c(Comma=",", Semicolon=";", Tab="\t"), ","),
        shiny::selectInput("fn", "Function", choices = c("create_ci_graph", "make_hist")),
        shiny::uiOutput("arg_ui"),
        shiny::actionButton("run", "Draw"),
        shiny::downloadButton("download_html", "Download chart (HTML)")
      ),
      shiny::mainPanel(
        shiny::verbatimTextOutput("status"),
        highcharter::highchartOutput("chart", height = "600px"),
        shiny::tags$hr(),
        shiny::tableOutput("head")
      )
    )
  )
}
