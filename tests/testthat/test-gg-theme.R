# tests/testthat/test-gg-theme.R
#
# Covers the gg_theme() resolver and its integration across the full stack:
#
#   gg_theme()          - name resolution, object pass-through, errors
#   hd_set_theme()      - gg_theme parameter: sets / restores session option
#   hd_opts()           - gg_theme field stored and retrieved
#   ggplot_engine()     - theme actually applied to output figure
#   hd_make()           - end-to-end: per-figure opts vs session default
#
# HOW WE INSPECT THE APPLIED THEME
#   ggplot2 stores the active theme in p$theme (a list of element objects).
#   After adding a theme via `p + theme_classic()`, p$theme is populated with
#   that theme's elements.  We can compare class strings and specific element
#   properties to verify the correct theme was applied.
#
#   We avoid comparing full theme objects with expect_equal() because theme
#   objects contain environment references that differ between calls.
#   Instead we compare named properties that differ reliably between themes,
#   e.g. panel.background fill colour (grey in theme_grey, white in
#   theme_classic / theme_minimal) or the class of panel.grid elements.

# ── Shared fixtures ────────────────────────────────────────────────────────────

spec <- hd_spec(survey_df, "age", "pct", group = "sex")
opts_base <- hd_opts(title = "Theme test")

# Helper: extract a theme element property from a built ggplot
theme_el <- function(fig, element) {
  ggplot2::ggplot_build(fig)$plot$theme[[element]]
}

# Helper: build fig with a given gg_theme name and return the resolved theme
built_theme <- function(gg_theme_val) {
  opts <- hd_opts(title = "t", gg_theme = gg_theme_val)
  fig  <- hd_make(spec, "column", opts, backend = "ggplot2")
  ggplot2::ggplot_build(fig)$plot$theme
}


# ══════════════════════════════════════════════════════════════════════════════
# 1.  gg_theme() — resolver unit tests
# ══════════════════════════════════════════════════════════════════════════════

test_that("gg_theme: returns a ggplot2 theme object for every built-in name", {
  nms <- c("minimal", "classic", "bw", "light", "dark", "void", "grey", "gray")
  for (nm in nms) {
    t <- gg_theme(nm)
    expect_true(inherits(t, "theme"), label = paste("gg_theme name:", nm))
  }
})

test_that("gg_theme: NULL reads session option highdir.gg_theme", {
  withr::with_options(list(highdir.gg_theme = "classic"), {
    t <- gg_theme(NULL)
    expect_s3_class(t, "theme")
    # theme_classic has no panel grid lines; theme_minimal does
    # panel.grid is element_blank() in classic but element_line() in minimal
    expect_true(inherits(t$panel.grid, "element_blank"))
  })
})

test_that("gg_theme: falls back to 'classic' when session option unset", {
  withr::with_options(list(highdir.gg_theme = NULL), {
    t <- gg_theme(NULL)
    expect_s3_class(t, "theme")
    # theme_classic removes panel grid lines entirely (element_blank)
    expect_true(inherits(t$panel.grid, "element_blank") ||
                inherits(t$panel.grid.major, "element_blank"),
                label = "classic fallback has no visible panel grid")
  })
})

test_that("gg_theme: theme object passed directly is returned as-is", {
  obj <- ggplot2::theme_bw(base_size = 18)
  t   <- gg_theme(obj)
  expect_identical(t, obj)
})

test_that("gg_theme: theme object with extra modifications is returned as-is", {
  obj <- ggplot2::theme_classic() +
    ggplot2::theme(legend.position = "top")
  t <- gg_theme(obj)
  expect_identical(t, obj)
})

test_that("gg_theme: errors on unknown name string", {
  expect_error(gg_theme("neon_banana"), "Unknown gg_theme name")
})

test_that("gg_theme: errors on non-string non-theme input", {
  expect_error(gg_theme(42),      "must be a single theme name string")
  expect_error(gg_theme(TRUE),    "must be a single theme name string")
  expect_error(gg_theme(list()),  "must be a single theme name string")
})

test_that("gg_theme: grey and gray are aliases for the same theme", {
  t_grey <- gg_theme("grey")
  t_gray <- gg_theme("gray")
  # Both should produce theme_grey — compare panel.background fill
  expect_equal(
    t_grey$panel.background$fill,
    t_gray$panel.background$fill
  )
})


# ══════════════════════════════════════════════════════════════════════════════
# 2.  hd_set_theme() — gg_theme parameter
# ══════════════════════════════════════════════════════════════════════════════

test_that("hd_set_theme: gg_theme sets session option", {
  withr::with_options(list(highdir.gg_theme = "minimal"), {
    hd_set_theme(gg_theme = "classic")
    expect_equal(getOption("highdir.gg_theme"), "classic")
  })
})

test_that("hd_set_theme: gg_theme returns previous value invisibly", {
  withr::with_options(list(highdir.gg_theme = "minimal"), {
    prev <- hd_set_theme(gg_theme = "bw")
    expect_equal(prev$highdir.gg_theme, "minimal")
  })
})

test_that("hd_set_theme: previous value can be used to restore option", {
  withr::with_options(list(highdir.gg_theme = "minimal"), {
    prev <- hd_set_theme(gg_theme = "classic")
    options(prev)
    expect_equal(getOption("highdir.gg_theme"), "minimal")
  })
})

test_that("hd_set_theme: gg_theme NULL does not change existing option", {
  withr::with_options(list(highdir.gg_theme = "bw"), {
    hd_set_theme(gg_theme = NULL)
    expect_equal(getOption("highdir.gg_theme"), "bw")
  })
})

test_that("hd_set_theme: gg_theme accepts a theme object directly", {
  obj <- ggplot2::theme_bw(base_size = 14)
  withr::with_options(list(highdir.gg_theme = "minimal"), {
    hd_set_theme(gg_theme = obj)
    stored <- getOption("highdir.gg_theme")
    expect_true(inherits(stored, "theme"))
    expect_identical(stored, obj)
  })
})

test_that("hd_set_theme: hc_theme and gg_theme can be set simultaneously", {
  withr::with_options(list(highdir.hc_theme = "default",
                           highdir.gg_theme = "minimal"), {
    hd_set_theme(hc_theme = "gridlight", gg_theme = "classic")
    expect_equal(getOption("highdir.hc_theme"), "gridlight")
    expect_equal(getOption("highdir.gg_theme"), "classic")
  })
})


# ══════════════════════════════════════════════════════════════════════════════
# 3.  hd_opts() — gg_theme field
# ══════════════════════════════════════════════════════════════════════════════

test_that("hd_opts: gg_theme stored as NULL by default", {
  opts <- hd_opts()
  expect_null(opts$gg_theme)
})

test_that("hd_opts: gg_theme name string stored correctly", {
  opts <- hd_opts(gg_theme = "classic")
  expect_equal(opts$gg_theme, "classic")
})

test_that("hd_opts: gg_theme theme object stored correctly", {
  obj  <- ggplot2::theme_bw(base_size = 16)
  opts <- hd_opts(gg_theme = obj)
  expect_identical(opts$gg_theme, obj)
})

test_that("hd_opts: class is preserved with gg_theme set", {
  opts <- hd_opts(gg_theme = "classic")
  expect_s3_class(opts, "hd_opts")
})


# ══════════════════════════════════════════════════════════════════════════════
# 4.  ggplot_engine integration — theme is applied to the output figure
# ══════════════════════════════════════════════════════════════════════════════

# Strategy: theme_classic() removes panel grid lines (element_blank).
# theme_grey() (ggplot2 default) has panel.grid as element_line with colour.
# This structural difference is stable and testable without hard-coding colours.

test_that("ggplot_engine: theme_classic applied — panel grid is blank", {
  opts <- hd_opts(title = "t", gg_theme = "classic")
  fig  <- hd_make(spec, "column", opts, backend = "ggplot2")
  t    <- ggplot2::ggplot_build(fig)$plot$theme
  expect_true(inherits(t$panel.grid, "element_blank") ||
              inherits(t$panel.grid.major, "element_blank"),
              label = "classic theme has no visible panel grid")
})

test_that("ggplot_engine: theme_minimal applied — white  background fill", {
  opts <- hd_opts(title = "t", gg_theme = "minimal")
  fig  <- hd_make(spec, "column", opts, backend = "ggplot2")
  t    <- ggplot2::ggplot_build(fig)$plot$theme
  # theme_minimal: panel.background fill is NA (transparent)
  fill <- t$plot.background$fill
  expect_true(is.na(fill) || identical(fill, "white"),
              label = "minimal theme has white plot background")
})

test_that("ggplot_engine: theme_bw applied — panel background is white", {
  opts <- hd_opts(title = "t", gg_theme = "bw")
  fig  <- hd_make(spec, "column", opts, backend = "ggplot2")
  t    <- ggplot2::ggplot_build(fig)$plot$theme
  fill <- t$panel.background$fill
  expect_equal(fill, "white",
               label = "bw theme has white panel background")
})

test_that("ggplot_engine: theme object in opts applied directly", {
  obj  <- ggplot2::theme_bw(base_size = 18)
  opts <- hd_opts(title = "t", gg_theme = obj)
  fig  <- hd_make(spec, "column", opts, backend = "ggplot2")
  t    <- ggplot2::ggplot_build(fig)$plot$theme
  # base_size is stored in the top-level text element as an absolute value.
  # axis.text$size stores rel(0.8) — a relative multiplier, not the final px
  # size — so checking t$text$size is the correct way to verify base_size = 18.
  expect_equal(t$text$size, 18)
})

test_that("ggplot_engine: session default used when opts$gg_theme is NULL", {
  withr::with_options(list(highdir.gg_theme = "classic"), {
    opts <- hd_opts(title = "t")   # gg_theme = NULL → falls through to session
    fig  <- hd_make(spec, "column", opts, backend = "ggplot2")
    t    <- ggplot2::ggplot_build(fig)$plot$theme
    expect_true(inherits(t$panel.grid, "element_blank") ||
                inherits(t$panel.grid.major, "element_blank"),
                label = "session classic theme has no visible panel grid")
  })
})

test_that("ggplot_engine: opts gg_theme overrides session default", {
  # Session says classic (no grid), opts says bw (white bg, has grid)
  withr::with_options(list(highdir.gg_theme = "classic"), {
    opts <- hd_opts(title = "t", gg_theme = "bw")
    fig  <- hd_make(spec, "column", opts, backend = "ggplot2")
    t    <- ggplot2::ggplot_build(fig)$plot$theme
    # bw has white panel background — classic does not set this to white
    fill <- t$panel.background$fill
    expect_equal(fill, "white",
                 label = "per-figure bw overrides session classic")
  })
})


# ══════════════════════════════════════════════════════════════════════════════
# 5.  hd_make() end-to-end — theme does not affect highcharter backend
# ══════════════════════════════════════════════════════════════════════════════

test_that("hd_make: gg_theme in opts does not break highcharter output", {
  opts <- hd_opts(title = "t", gg_theme = "classic")
  fig  <- hd_make(spec, "column", opts, backend = "highcharter")
  expect_true(is_highchart(fig))
})

test_that("hd_make: gg_theme object in opts does not break highcharter", {
  obj  <- ggplot2::theme_bw()
  opts <- hd_opts(title = "t", gg_theme = obj)
  fig  <- hd_make(spec, "column", opts, backend = "highcharter")
  expect_true(is_highchart(fig))
})


# ══════════════════════════════════════════════════════════════════════════════
# 6.  Font is applied on top of the theme (ordering guard)
# ══════════════════════════════════════════════════════════════════════════════

test_that("font option is preserved regardless of gg_theme", {
  withr::with_options(list(highdir.font = "mono"), {
    for (nm in c("minimal", "classic", "bw")) {
      opts <- hd_opts(title = "t", gg_theme = nm)
      fig  <- hd_make(spec, "column", opts, backend = "ggplot2")
      t    <- ggplot2::ggplot_build(fig)$plot$theme
      expect_equal(t$text$family, "mono",
                   label = paste("font preserved with gg_theme =", nm))
    }
  })
})
