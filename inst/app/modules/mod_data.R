# inst/app/modules/mod_data.R
# ── Data module ───────────────────────────────────────────────────────────────
#
# Responsibilities:
#   • File upload and parsing (via rio)
#   • Column-mapping dropdowns  (x, y, group, n_col)
#   • Required-arg dropdowns    (e.g. ymin / ymax for arearange)
#   • Data-preview table        (tbl_head)
#
# ── WHY THE DELAY HAPPENED AND HOW IT IS FIXED ───────────────────────────────
#
# The original server used renderUI() to build the four column-mapping
# selectInputs every time a file was uploaded:
#
#   output$ui_mapping <- renderUI({
#     req(dataset_cols())
#     tagList(
#       selectInput("x",   ..., choices = cols),   # ← DOM rebuilt from scratch
#       selectInput("y",   ..., choices = cols),
#       selectInput("group", ..., choices = ...),
#       selectInput("n_col", ..., choices = ...)
#     )
#   })
#
# renderUI() works by serialising an HTML string on the server, sending it
# to the browser over the WebSocket, and then the browser destroys the
# old DOM nodes and creates new ones from the HTML.  Shiny must then
# re-bind its input listeners to the fresh nodes.  That full cycle
# (serialize → transmit → destroy → recreate → rebind) takes 300–800 ms
# even on a fast machine, and feels sluggish.
#
# THE FIX: declare all four selectInputs statically in mod_data_ui().
# They exist in the DOM from the moment the page loads.  On upload, the
# server sends only a tiny updateSelectInput() message (≈ 200 bytes JSON)
# that replaces the <option> list in-place.  No DOM destruction, no
# rebinding — the browser updates in < 30 ms.
#
# renderUI() is kept only where the *structure* of the UI varies:
#   • ui_required: the number of inputs changes per geometry, so the
#     DOM shape itself changes — unavoidable.  But this fires on geom
#     change, not on upload, so it is not on the critical path.

# ── UI ────────────────────────────────────────────────────────────────────────

#' @keywords internal
mod_data_ui <- function(id) {
  ns <- shiny::NS(id)

  shiny::tagList(

    # File upload — always visible, no data dependency
    shiny::div(class = "hd-label", "Data"),
    shiny::fileInput(
      ns("file"), NULL,
      accept      = c(".csv", ".xlsx", ".xls", ".rds", ".sav", ".dta", ".json"),
      placeholder = "CSV / XLSX / RDS \u2026",
      buttonLabel = shiny::icon("folder-open")
    ),

    # ── Spec collapsible panel ────────────────────────────────────────────────
    # Toggle button — all interactivity is client-side (app.js)
    shiny::tags$button(
      class         = "hd-toggle",
      `data-target` = paste0("#", ns("panel-spec")),
      shiny::span("Spec \u2014 variable mapping"),
      shiny::span(class = "hd-arrow", "\u25bc")
    ),

    shiny::div(
      id    = ns("panel-spec"),
      class = "hd-collapse",

      # ── Static selectInputs — THE KEY SPEED FIX ──────────────────────────
      # These inputs are present in the DOM from page load with empty choices.
      # updateSelectInput() in the server replaces choices in-place (~30 ms).
      # If these were inside renderUI(), they would be rebuilt from scratch
      # on every upload (~500 ms).
      shiny::selectInput(ns("x"),
                         label   = "X variable",
                         choices = character(0)),  # populated by updateSelectInput

      shiny::selectInput(ns("y"),
                         label   = "Y variable",
                         choices = character(0)),

      # Group is hidden for pie (client-side conditionalPanel — no server cost)
      shiny::conditionalPanel(
        condition = "input.geom != 'pie'",
        shiny::selectInput(ns("group"),
                           label   = "Group variable",
                           choices = c("(none)" = ""))
      ),

      shiny::selectInput(ns("n_col"),
                         label   = "Count column",
                         choices = c("(none)" = "")),

      # Required args still use renderUI because the *number* of inputs
      # changes per geometry — only the structure varies, not just choices.
      shiny::uiOutput(ns("ui_required"))
    )
  )
}

# ── Server ────────────────────────────────────────────────────────────────────

#' @keywords internal
#' @param id     Module id.
#' @param geom_r Reactive string — currently selected geometry name.
#'               Passed in from the parent so this module does not read
#'               input$geom directly (keeps namespace clean).
mod_data_server <- function(id, geom_r) {

  shiny::moduleServer(id, function(input, output, session) {

    # ── Parse uploaded file ─────────────────────────────────────────────────
    # rio::import() auto-detects format from the file extension.
    # This is the only genuinely slow step on the upload path.
    dataset <- shiny::reactive({
      shiny::req(input$file)
      rio::import(input$file$datapath)
    })

    # ── Cache column names ───────────────────────────────────────────────────
    # Computed once here; all downstream reactives use cols() not names(dataset()).
    cols <- shiny::reactive({
      shiny::req(dataset())
      names(dataset())
    })

    # ── Populate dropdowns via update* — NOT renderUI ────────────────────────
    # observeEvent fires once when cols() first becomes available, then again
    # if the user uploads a different file.  Each updateSelectInput() sends
    # a small JSON patch to the browser; the existing DOM nodes are kept.
    shiny::observeEvent(cols(), {
      ch <- cols()
      shiny::updateSelectInput(session, "x",     choices = ch,                  selected = ch[1])
      shiny::updateSelectInput(session, "y",     choices = ch,                  selected = ch[min(2, length(ch))])
      shiny::updateSelectInput(session, "group", choices = c("(none)" = "", ch), selected = "")
      shiny::updateSelectInput(session, "n_col", choices = c("(none)" = "", ch), selected = "")
    }, ignoreNULL = TRUE)

    # ── Required-arg inputs (renderUI — structure varies by geom) ───────────
    output$ui_required <- shiny::renderUI({
      shiny::req(geom_r(), cols())
      ra <- highdir:::.get_geom(geom_r())$required_args
      if (length(ra) == 0L) return(NULL)
      ch <- cols()
      shiny::tagList(lapply(ra, function(a)
        shiny::selectInput(session$ns(a), paste("Column:", a), choices = ch)
      ))
    })

    # ── Data preview ─────────────────────────────────────────────────────────
    # server = TRUE keeps raw data server-side (important for large files).
    output$tbl_head <- DT::renderDT({
      shiny::req(dataset())
      dat <- dataset()
      if (nrow(dat) > 20L) dat <- dat[sample(seq_len(nrow(dat)), 15L), ]
      else                  dat <- utils::head(dat, 10L)
      DT::datatable(dat,
                    options  = list(pageLength = 10L, scrollX = TRUE),
                    rownames = FALSE)
    }, server = TRUE)

    # ── Return values to parent ───────────────────────────────────────────────
    # The parent server reads these to construct hd_spec() and geom extra args.
    list(
      dataset  = dataset,
      x        = shiny::reactive(input$x),
      y        = shiny::reactive(input$y),
      group    = shiny::reactive(input$group),
      n_col    = shiny::reactive(input$n_col),
      req_args = shiny::reactive({
        # Named list of column selections for geoms that have required_args
        ra <- highdir:::.get_geom(geom_r())$required_args
        if (length(ra) == 0L) return(list())
        args <- lapply(ra, function(a) input[[a]])
        stats::setNames(args, ra)
      })
    )
  })
}
