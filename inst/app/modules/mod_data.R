# inst/app/modules/mod_data.R
# ── Data module ───────────────────────────────────────────────────────────────
#
# Responsibilities:
#   • File upload and parsing (via rio)
#   • Column-mapping dropdowns  (x, y, group, n_col)
#   • Required-arg dropdowns    (ymin / ymax for arearange)
#   • Data-preview table        (tbl_head)
#
# ── SPEED PRINCIPLE: updateSelectInput everywhere, renderUI nowhere ────────────
#
# renderUI() rebuilds DOM nodes from scratch on every trigger:
#   serialize HTML → transmit → browser destroys nodes → recreates → rebinds
#   = 300–800 ms perceived lag
#
# updateSelectInput() sends a tiny JSON patch (~200 bytes) that replaces
# only the <option> list in an existing node — no DOM destruction, no
# rebinding, < 30 ms.
#
# Applied consistently here:
#   x / y / group / n_col  — static in UI, updated via updateSelectInput
#   ymin / ymax            — static in UI, shown via conditionalPanel,
#                            updated via updateSelectInput
#

# ── UI ────────────────────────────────────────────────────────────────────────

#' @keywords internal
mod_data_ui <- function(id) {
  ns <- shiny::NS(id)

  shiny::tagList(

    shiny::div(class = "hd-label", "Data"),
    shiny::fileInput(
      ns("file"), NULL,
      accept      = c(".csv", ".xlsx", ".xls", ".rds", ".sav", ".dta", ".json"),
      placeholder = "CSV / XLSX / RDS \u2026",
      buttonLabel = shiny::icon("folder-open")
    ),

    shiny::tags$button(
      class         = "hd-toggle",
      `data-target` = paste0("#", ns("panel-spec")),
      shiny::span("Spec \u2014 variable mapping"),
      shiny::span(class = "hd-arrow", "\u25bc")
    ),

    shiny::div(
      id    = ns("panel-spec"),
      class = "hd-collapse",

      # ── Standard column-mapping inputs (always visible) ───────────────────
      # All declared statically — choices populated by updateSelectInput()
      # in observeEvent(cols()).  Zero lag on upload.
      shiny::selectInput(ns("x"),
                         label   = "X variable",
                         choices = character(0)),

      shiny::selectInput(ns("y"),
                         label   = "Y variable",
                         choices = character(0)),

      shiny::conditionalPanel(
        condition = "input.geom != 'pie'",
        shiny::selectInput(ns("group"),
                           label   = "Group variable",
                           choices = c("(none)" = ""))
      ),

      shiny::selectInput(ns("n_col"),
                         label   = "Count column",
                         choices = c("(none)" = "")),

      # ── Required-arg inputs — static, shown/hidden by conditionalPanel ────
      # arearange: ymin + ymax
      shiny::conditionalPanel(
        condition = "input.geom == 'arearange'",
        shiny::selectInput(ns("ymin"),
                           label   = "Column: ymin",
                           choices = character(0)),
        shiny::selectInput(ns("ymax"),
                           label   = "Column: ymax",
                           choices = character(0))
      )
    )
  )
}

# ── Server ────────────────────────────────────────────────────────────────────

#' @keywords internal
#' @param id     Module id.
#' @param geom_r Reactive string — currently selected geometry name.
mod_data_server <- function(id, geom_r) {

  shiny::moduleServer(id, function(input, output, session) {

    # ── Parse uploaded file ──────────────────────────────────────────────────
    dataset <- shiny::reactive({
      shiny::req(input$file)
      rio::import(input$file$datapath)
    })

    # ── Cache column names ────────────────────────────────────────────────────
    cols <- shiny::reactive({
      shiny::req(dataset())
      names(dataset())
    })

    # ── Populate ALL column dropdowns in one observer ─────────────────────────
    # Fires once when cols() becomes available (upload) and again if a new
    # file is uploaded.  Covers x/y/group/n_col AND the required-arg inputs
    # (ymin/ymax) in a single round-trip — no renderUI involved.
    shiny::observeEvent(cols(), {
      ch <- cols()
      # Standard mapping inputs
      shiny::updateSelectInput(session, "x",
        choices  = ch,
        selected = ch[1])
      shiny::updateSelectInput(session, "y",
        choices  = ch,
        selected = ch[min(2, length(ch))])
      shiny::updateSelectInput(session, "group",
        choices  = c("(none)" = "", ch),
        selected = "")
      shiny::updateSelectInput(session, "n_col",
        choices  = c("(none)" = "", ch),
        selected = "")

      # Required-arg inputs — updated here, shown/hidden by conditionalPanel
      # arearange: ymin defaults to 3rd col if available, ymax to 4th
      shiny::updateSelectInput(session, "ymin",
        choices  = ch,
        selected = ch[min(3, length(ch))])
      shiny::updateSelectInput(session, "ymax",
        choices  = ch,
        selected = ch[min(4, length(ch))])
    }, ignoreNULL = TRUE)

    # ── Data preview ──────────────────────────────────────────────────────────
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
    list(
      dataset  = dataset,
      x        = shiny::reactive(input$x),
      y        = shiny::reactive(input$y),
      group    = shiny::reactive(input$group),
      n_col    = shiny::reactive(input$n_col),
      # req_args: named list of required-arg column selections for the current
      # geom.  Read from input$ directly — IDs match names(required_args)
      # because the static inputs above use ns("ymin"), ns("ymax") etc.
      # req_args reads required_args as a NAMED LIST (same structure as
      # optional_args).  names(ra) gives the arg names (e.g. 'ymin', 'ymax');
      # input[[a]] reads the current column selection from the namespaced
      # selectInput (ns('ymin'), ns('ymax')) declared statically above.
      req_args = shiny::reactive({
        ra <- highdir:::.get_geom(geom_r())$required_args
        if (length(ra) == 0L) return(list())
        arg_names <- names(ra)
        stats::setNames(
          lapply(arg_names, function(a) input[[a]]),
          arg_names
        )
      })
    )
  })
}
