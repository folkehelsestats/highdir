# inst/app/server.R ── highdir Shiny app server

server <- function(input, output, session) {

  # ── Data ───────────────────────────────────────────────────────────────────

  dataset <- shiny::reactive({
    shiny::req(input$file)
    rio::import(input$file$datapath)
  })

  output$tbl_head <- shiny::renderTable({
    shiny::req(dataset())
    utils::head(dataset(), 10)
  })

  # ── Dynamic UI ─────────────────────────────────────────────────────────────

  output$ui_mapping <- shiny::renderUI({
    shiny::req(dataset())
    cols <- names(dataset())
    shiny::tagList(
      shiny::selectInput("x",     "X variable",             choices = cols),
      shiny::selectInput("y",     "Y variable",             choices = cols),
      # Pie ignores group — hide it when geom = pie
      shiny::conditionalPanel(
        "input.geom != 'pie'",
        shiny::selectInput("group", "Group variable",
                           choices = c("(none)" = "", cols))
      ),
      shiny::selectInput("n_col", "Count column (tooltip)",
                         choices = c("(none)" = "", cols))
    )
  })

  output$ui_required <- shiny::renderUI({
    shiny::req(input$geom, dataset())
    ra <- get_geom(input$geom)$required_args
    if (length(ra) == 0) return(NULL)
    cols <- names(dataset())
    shiny::tagList(lapply(ra, function(a)
      shiny::selectInput(a, paste("Column:", a), choices = cols)))
  })

  output$ui_downloads <- shiny::renderUI({
    shiny::req(input$backend)
    if (input$backend == "highcharter") {
      btns <- list(
        shiny::downloadButton("dl_json", "JSON"),
        shiny::downloadButton("dl_html", "HTML")
      )
      if (.has_webshot2)
        btns <- c(btns, list(shiny::downloadButton("dl_hc_png", "PNG")))
      do.call(shiny::tagList, btns)
    } else {
      shiny::tagList(
        shiny::downloadButton("dl_gg_png", "PNG"),
        shiny::downloadButton("dl_gg_svg", "SVG")
      )
    }
  })

  # ── Helpers ────────────────────────────────────────────────────────────────

  parsed_colors <- shiny::reactive({
    raw <- trimws(input$colors %||% "")
    if (!nzchar(raw)) return(NULL)
    strsplit(raw, "\\s*,\\s*")[[1]]
  })

  geom_args <- shiny::reactive({
    shiny::req(input$geom)
    ra <- get_geom(input$geom)$required_args
    if (length(ra) == 0) return(list())
    args <- lapply(ra, function(a) input[[a]])
    stats::setNames(args, ra)
  })

  dl_basename <- shiny::reactive({
    raw <- trimws(input$dl_filename %||% "")
    if (!nzchar(raw)) return(paste0("highdir-figure_", Sys.Date()))
    tools::file_path_sans_ext(raw)
  })

  # ── Spec + opts ────────────────────────────────────────────────────────────

  the_spec <- shiny::reactive({
    shiny::req(dataset(), input$x, input$y)
    hd_spec(
      data  = dataset(),
      x     = input$x,
      y     = input$y,
      group = if (nzchar(input$group  %||% "")) input$group  else NULL,
      n     = if (nzchar(input$n_col  %||% "")) input$n_col  else NULL
    )
  })

  the_opts <- shiny::reactive({
    hd_opts(
      title    = if (nzchar(input$title    %||% "")) input$title    else NULL,
      subtitle = if (nzchar(input$subtitle %||% "")) input$subtitle else NULL,
      caption  = if (nzchar(input$caption  %||% "")) input$caption  else NULL,
      colors   = parsed_colors(),
      hc_theme = input$hc_theme %||% NULL
    )
  })

  # ── Rendering ──────────────────────────────────────────────────────────────

  hc_fig <- shiny::eventReactive(input$run, {
    shiny::req(input$backend == "highcharter", the_spec())
    do.call(hd_make, c(
      list(spec       = the_spec(),
           type       = input$geom,
           opts       = the_opts(),
           backend    = "highcharter",
           use_js     = isTRUE(input$use_js),
           smooth     = isTRUE(input$smooth),
           dot_size   = input$dot_size   %||% 4L,
           inner_size  = input$inner_size  %||% "0%",
           level       = input$map_level    %||% "county",
           value_lab   = if (nzchar(input$map_value_lab %||% "")) input$map_value_lab else NULL,
           low_col     = input$map_low_col   %||% "#C6DBEF",
           high_col    = input$map_high_col  %||% "#025169",
           na_fill     = input$map_na_fill   %||% "#D3D3D3"),
      geom_args()
    ))
  })

  gg_fig <- shiny::eventReactive(input$run, {
    shiny::req(input$backend == "ggplot2", the_spec())
    do.call(hd_make, c(
      list(spec       = the_spec(),
           type       = input$geom,
           opts       = the_opts(),
           backend    = "ggplot2",
           smooth     = isTRUE(input$smooth),
           dot_size   = input$dot_size   %||% 4L,
           inner_size  = input$inner_size  %||% "0%",
           level       = input$map_level    %||% "county",
           value_lab   = if (nzchar(input$map_value_lab %||% "")) input$map_value_lab else NULL,
           low_col     = input$map_low_col   %||% "#C6DBEF",
           high_col    = input$map_high_col  %||% "#025169",
           na_fill     = input$map_na_fill   %||% "#D3D3D3"),
      geom_args()
    ))
  })

  output$hc_out <- highcharter::renderHighchart(hc_fig())
  output$gg_out <- shiny::renderPlot(gg_fig())

  # ── R code preview ─────────────────────────────────────────────────────────

  output$code_preview <- shiny::renderText({
    shiny::req(input$x, input$y, input$geom, input$backend)

    grp_l  <- if (nzchar(input$group    %||% ""))
                paste0('  group  = "', input$group,    '",\n') else ""
    n_l    <- if (nzchar(input$n_col    %||% ""))
                paste0('  n      = "', input$n_col,    '",\n') else ""
    ttl_l  <- if (nzchar(input$title    %||% ""))
                paste0('  title    = "', input$title,    '",\n') else ""
    sub_l  <- if (nzchar(input$subtitle %||% ""))
                paste0('  subtitle = "', input$subtitle, '",\n') else ""
    cap_l  <- if (nzchar(input$caption  %||% ""))
                paste0('  caption  = "', input$caption,  '",\n') else ""

    extra_str <- {
      ex <- geom_args()
      if (length(ex))
        paste0(",\n  ", paste(names(ex), paste0('"', unlist(ex), '"'),
                              sep = " = ", collapse = ",\n  "))
      else ""
    }

    js_str   <- if (input$backend == "highcharter")
                  paste0(',\n  use_js = ', isTRUE(input$use_js))     else ""
    smo_str  <- if (input$geom == "line")
                  paste0(',\n  smooth = ', isTRUE(input$smooth))     else ""
    pie_str  <- if (input$geom == "pie" && nzchar(input$inner_size %||% ""))
                  paste0(',\n  inner_size = "', input$inner_size, '"') else ""
    map_str  <- if (input$geom == "map")
                  paste0(',\n  level = "', input$map_level %||% "county", '"')
                else ""

    paste0(
      "spec <- hd_spec(\n",
      "  data  = your_data,\n",
      '  x     = "', input$x, '",\n',
      '  y     = "', input$y, '",\n',
      grp_l, n_l,
      ")\n\n",
      "opts <- hd_opts(\n",
      ttl_l, sub_l, cap_l,
      ")\n\n",
      "hd_make(\n",
      "  spec    = spec,\n",
      "  opts    = opts,\n",
      '  type    = "', input$geom,    '",\n',
      '  backend = "', input$backend, '"',
      js_str, smo_str, pie_str, map_str, extra_str,
      "\n)"
    )
  })

  # ── Downloads ──────────────────────────────────────────────────────────────

  .dl <- function(ext, fig_r) {
    shiny::downloadHandler(
      filename = function() paste0(dl_basename(), ".", ext),
      content  = function(file) {
        shiny::req(fig_r())
        hd_save(fig_r(), file, type = ext)
      }
    )
  }

  output$dl_json   <- .dl("json", hc_fig)
  output$dl_html   <- .dl("html", hc_fig)
  output$dl_hc_png <- .dl("png",  hc_fig)
  output$dl_gg_png <- .dl("png",  gg_fig)
  output$dl_gg_svg <- .dl("svg",  gg_fig)
}
