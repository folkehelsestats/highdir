# inst/app/global.R
# ── Loaded by Shiny before ui.R and server.R ──────────────────────────────────
#
# Shiny's load order is:  global.R → ui.R → server.R
#
# Modules MUST be sourced here, not in server.R.
# ui.R calls mod_data_ui(), mod_opts_ui(), mod_figure_ui() at parse time —
# before server.R is ever read.  Sourcing modules inside server() is too late.

library(highdir)

# ── Source modules ─────────────────────────────────────────────────────────────
# local = TRUE keeps each module's internal helpers out of the global env.
source("modules/mod_data.R",    local = FALSE)
source("modules/mod_opts.R",    local = FALSE)
source("modules/mod_figure.R",  local = FALSE)

# ── Runtime-only app dependencies ─────────────────────────────────────────────
# rio and DT are used exclusively in inst/app/ and are intentionally NOT
# declared in DESCRIPTION (Suggests) to avoid R CMD check warnings about
# packages listed in Suggests but never called from R/*.R.
# They are checked here at app launch time instead.
.has_webshot2 <- requireNamespace("webshot2", quietly = TRUE)

if (!requireNamespace("rio", quietly = TRUE))
  stop(
    "The 'rio' package is required to run the highdir Shiny app.\n",
    "Install it with:  install.packages('rio')",
    call. = FALSE
  )

if (!requireNamespace("DT", quietly = TRUE))
  stop(
    "The 'DT' package is required to run the highdir Shiny app.\n",
    "Install it with:  install.packages('DT')",
    call. = FALSE
  )

# ── geom_opts_ui() ────────────────────────────────────────────────────────────
#
# Called once from ui.R at app startup (before any user interaction).
# Reads optional_args for every registered geometry from the highdir registry
# and returns a tagList of conditionalPanels — one per geom.
#
# Each panel is only visible when input$geom matches its geometry name, making
# the whole thing pure client-side.  No renderUI, no server round-trips.
#
# Widget type dispatch (mirrors the old renderUI logic so input IDs are
# identical — geom_inputs_r() in server.R reads them the same way):
#   logical   → checkboxInput   (inputId = nm)
#   numeric   → numericInput    (inputId = nm)
#   "level"   → selectInput     (special-cased: county / municipality)
#   character → textInput       (inputId = nm, value = default)
#   NULL      → textInput       (inputId = nm, value = "")
#
# The hd-toggle + hd-collapse pattern is identical to mod_opts_ui() and
# mod_data_ui() — same CSS classes, same app.js click handler, no new code.

.geom_widget <- function(nm, entry) {
  def <- entry$default

  # Helper text — short description shown below widget
  desc_short <- entry$desc %||% ""
  if (nchar(desc_short) > 80)
    desc_short <- paste0(substr(desc_short, 1, 80), "\u2026")
  helper <- shiny::tags$p(
    style = "font-size:10px; color:#8b949e; margin:-3px 0 5px;",
    desc_short
  )

  widget <- if (nm == "level") {
    shiny::selectInput(nm, nm,
      choices  = c("County" = "county", "Municipality" = "municipality"),
      selected = def %||% "county")

  } else if (is.logical(def) ||
             identical(def, TRUE) || identical(def, FALSE)) {
    shiny::checkboxInput(nm, nm, value = isTRUE(def))

  } else if (is.numeric(def)) {
    shiny::numericInput(nm, nm, value = def)

  } else {
    ph <- if (!is.null(def)) as.character(def) else nm
    shiny::textInput(nm, nm,
      value       = if (!is.null(def)) as.character(def) else "",
      placeholder = ph)
  }

  shiny::div(widget, helper)
}

geom_opts_ui <- function() {
  geom_names <- highdir::list_geoms()

  panels <- lapply(geom_names, function(g) {
    geom_def <- highdir:::.get_geom(g)
    oa       <- geom_def$optional_args

    # Panel id is stable and unique — used by app.js toggle handler
    panel_id  <- paste0("panel-geom-", g)
    toggle_id <- paste0("toggle-geom-", g)

    panel_body <- if (length(oa) == 0L) {
      shiny::tags$p(
        style = "font-size:11px; color:#8b949e; margin:2px 0 0;",
        "No extra options for this geometry."
      )
    } else {
      shiny::tagList(lapply(names(oa), function(nm) .geom_widget(nm, oa[[nm]])))
    }

    shiny::conditionalPanel(
      condition = paste0("input.geom == '", g, "'"),

      shiny::tags$button(
        id            = toggle_id,
        class         = "hd-toggle",
        `data-target` = paste0("#", panel_id),
        shiny::span(paste("Geom \u2014", g)),
        shiny::span(class = "hd-arrow", "\u25bc")
      ),

      shiny::div(
        id    = panel_id,
        class = "hd-collapse",
        panel_body
      )
    )
  })

  shiny::tagList(panels)
}
