#' @keywords internal
app_server <- function(input, output, session, ...) {
  # Optional run-time options from run_app(...):
  opts <- list(...)
  highdir_available <- requireNamespace("highdir", quietly = TRUE)

  dt <- shiny::reactive({
    req(input$file)
    data.table::fread(input$file$datapath, sep = input$sep, header = TRUE, data.table = TRUE)
  })
  output$head <- shiny::renderTable({ head(dt(), 10) })

  # Build dynamic args UI
  shiny::observeEvent(dt(), {
    d <- dt()
    cols <- names(d); nums <- cols[vapply(d, is.numeric, logical(1))]

    output$arg_ui <- shiny::renderUI({
      if (identical(input$fn, "make_hist")) {
        shiny::tagList(
          shiny::selectInput("hist_var", "Numeric column", nums),
          shiny::numericInput("hist_bins", "Bins", 30, min = 1, step = 1),
          shiny::checkboxInput("hist_prob", "Probability (density)", FALSE),
          shiny::textInput("hist_title", "Title", "Histogram"),
          shiny::textInput("hist_xlab", "X label", "")
        )
      } else {
        shiny::tagList(
          shiny::selectInput("ci_x", "X / category", cols),
          shiny::selectInput("ci_est", "Estimate", nums),
          shiny::selectInput("ci_low", "Lower CI", nums),
          shiny::selectInput("ci_high", "Upper CI", nums),
          shiny::selectInput("ci_group", "Group (optional)", c("<none>", cols)),
          shiny::textInput("ci_title", "Title", "CI graph")
        )
      }
    })
  })

  make_plot <- shiny::eventReactive(input$run, {
    req(dt())
    d <- data.table::copy(dt())

    if (identical(input$fn, "make_hist")) {
      req(input$hist_var)
      vals <- d[[input$hist_var]]
      # Try highdir::make_hist; fallback to highcharter if not present
      plt <- tryCatch({
        if (!highdir_available) stop("highdir not available")
        highdir::make_hist(
          x = vals,
          bins = input$hist_bins,
          probability = isTRUE(input$hist_prob),
          title = input$hist_title,
          xlab = input$hist_xlab
        )
      }, error = function(e) {
        brks <- pretty(vals, n = input$hist_bins)
        h <- hist(vals, breaks = brks, plot = FALSE)
        highcharter::highchart() |>
          highcharter::hc_chart(type = "column") |>
          highcharter::hc_title(text = input$hist_title) |>
          highcharter::hc_xAxis(title = list(text = input$hist_xlab),
                                categories = round(h$mids, 2)) |>
          highcharter::hc_add_series(name = if (isTRUE(input$hist_prob)) "Density" else "Count",
                                     data = if (isTRUE(input$hist_prob)) as.numeric(h$density) else as.numeric(h$counts))
      })
      return(plt)
    }

    # create_ci_graph branch
    req(input$ci_x, input$ci_est, input$ci_low, input$ci_high)
    grp <- if (!is.null(input$ci_group) && input$ci_group != "<none>") input$ci_group else NULL

    tryCatch({
      if (!highdir_available) stop("highdir not available")
      highdir::create_ci_graph(
        data = d,
        x = input$ci_x,
        estimate = input$ci_est,
        lower = input$ci_low,
        upper = input$ci_high,
        group = grp,
        title = input$ci_title
      )
    }, error = function(e) {
      # Fallback: CI with highcharter
      x <- d[[input$ci_x]]; est <- d[[input$ci_est]]; low <- d[[input$ci_low]]; high <- d[[input$ci_high]]
      df <- data.table::data.table(x = as.character(x), est = est, low = low, high = high)
      if (!is.null(grp)) df[, group := as.character(d[[grp]])]

      hc <- highcharter::highchart() |> highcharter::hc_title(text = input$ci_title)
      if (!is.null(grp)) {
        for (g in unique(df$group)) {
          sub <- df[group == g]
          hc <- hc |>
            highcharter::hc_xAxis(categories = sub$x, title = list(text = input$ci_x)) |>
            highcharter::hc_add_series(name = paste0(g, " est"), type = "column", data = as.numeric(sub$est)) |>
            highcharter::hc_add_series(name = paste0(g, " CI"), type = "errorbar",
              data = lapply(seq_len(nrow(sub)), function(i) c(sub$low[i], sub$high[i])))
        }
      } else {
        hc <- hc |>
          highcharter::hc_xAxis(categories = df$x, title = list(text = input$ci_x)) |>
          highcharter::hc_add_series(name = "Estimate", type = "column", data = as.numeric(df$est)) |>
          highcharter::hc_add_series(name = "CI", type = "errorbar",
            data = lapply(seq_len(nrow(df)), function(i) c(df$low[i], df$high[i])))
      }
      hc
    })
  })

  output$chart <- highcharter::renderHighchart({ req(make_plot()); make_plot() })
  output$status <- shiny::renderPrint({
    if (!highdir_available) {
      cat("Note: 'highdir' not loadable inside its own app (dev mode is fine). App using fallback renderer.")
    } else cat("highdir loaded. Ready.")
  })
  output$download_html <- shiny::downloadHandler(
    filename = function() paste0("highdir_chart_", Sys.Date(), ".html"),
    content  = function(file) htmlwidgets::saveWidget(make_plot(), file = file, selfcontained = TRUE)
  )
}
