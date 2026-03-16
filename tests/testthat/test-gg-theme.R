#
# Covers the gg_theme() resolver and its integration across the full stack:
#
#   gg_theme()          - name resolution, object pass-through, errors
#   hd_set_theme()      - gg_theme parameter: sets / restores session option
#   hd_opts()           - gg_theme field stored and retrieved
#   ggplot_engine()     - theme actually applied to output figure
#   hd_make()           - end-to-end: per-figure opts vs session default
#
# RETURN TYPE OF gg_theme()
#   gg_theme() returns an hd_gg_theme object — a list with two fields:
#     $theme  : ggplot2 theme object (with font baked in)
#     $colors : resolved colour vector or NULL
#   Tests that inspect the theme itself access gt$theme.
#   Tests that inspect resolved colours access gt$colors.
#
# HOW WE INSPECT THE APPLIED THEME (sections 4-6)
#   ggplot_engine() adds gt$theme to the plot and calls apply_gg_colors(gt$colors).
#   We verify by reading ggplot_build(fig)$plot$theme for structural properties
#   that differ reliably between themes, avoiding fragile full-object comparison.

# ── Shared fixtures ────────────────────────────────────────────────────────────

spec      <- hd_spec(survey_df, "age", "pct", group = "sex")
opts_base <- hd_opts(title = "Theme test")

# Helper: extract a theme element from a built ggplot
theme_el <- function(fig, element) {
  ggplot2::ggplot_build(fig)$plot$theme[[element]]
}


# ══════════════════════════════════════════════════════════════════════════════
# 1.  gg_theme() — unit tests on the returned hd_gg_theme object
# ══════════════════════════════════════════════════════════════════════════════

test_that("gg_theme: returns hd_gg_theme for every built-in name", {
  nms <- c("minimal", "classic", "bw", "light", "dark", "void", "grey", "gray")
  for (nm in nms) {
    gt <- gg_theme(nm)
    expect_true(inherits(gt, "hd_gg_theme"),  label = paste("class hd_gg_theme:", nm))
    expect_true(inherits(gt$theme, "theme"),   label = paste("$theme is theme:", nm))
  }
})

test_that("gg_theme: $colors is NULL when no colors supplied and no session option", {
  withr::with_options(list(highdir.colors = NULL), {
    gt <- gg_theme("classic")
    expect_null(gt$colors)
  })
})

test_that("gg_theme: $colors resolved from explicit argument", {
  pal <- c("#025169", "#7C145C")
  gt  <- gg_theme("classic", colors = pal)
  expect_equal(gt$colors, pal)
})

test_that("gg_theme: $colors resolved from session option when not explicit", {
  pal <- c("#AAAAAA", "#BBBBBB")
  withr::with_options(list(highdir.colors = pal), {
    gt <- gg_theme("classic")
    expect_equal(gt$colors, pal)
  })
})

test_that("gg_theme: explicit colors override session option", {
  session_pal <- c("#AAAAAA", "#BBBBBB")
  explicit_pal <- c("#025169", "#7C145C")
  withr::with_options(list(highdir.colors = session_pal), {
    gt <- gg_theme("classic", colors = explicit_pal)
    expect_equal(gt$colors, explicit_pal)
  })
})

test_that("gg_theme: NULL reads session option highdir.gg_theme", {
  withr::with_options(list(highdir.gg_theme = "classic"), {
    gt <- gg_theme(NULL)
    expect_true(inherits(gt$theme, "theme"))
    # theme_classic has no panel grid lines (element_blank)
    expect_true(inherits(gt$theme$panel.grid,       "element_blank") ||
                inherits(gt$theme$panel.grid.major, "element_blank"))
  })
})

test_that("gg_theme: falls back to 'classic' when session option unset", {
  withr::with_options(list(highdir.gg_theme = NULL), {
    gt <- gg_theme(NULL)
    expect_true(inherits(gt$theme, "theme"))
    expect_true(inherits(gt$theme$panel.grid,       "element_blank") ||
                inherits(gt$theme$panel.grid.major, "element_blank"),
                label = "classic fallback has no visible panel grid")
  })
})

test_that("gg_theme: theme object passed directly is wrapped in hd_gg_theme", {
  obj <- ggplot2::theme_bw(base_size = 18)
  gt  <- gg_theme(obj)
  expect_true(inherits(gt, "hd_gg_theme"))
  # Font not set, so theme is returned as-is inside $theme
  expect_equal(gt$theme$text$size, 18)
})

test_that("gg_theme: font baked into $theme", {
  gt <- gg_theme("classic", font = "mono")
  expect_equal(gt$theme$text$family, "mono")
})

test_that("gg_theme: font read from session option when not explicit", {
  withr::with_options(list(highdir.font = "serif"), {
    gt <- gg_theme("classic")
    expect_equal(gt$theme$text$family, "serif")
  })
})

test_that("gg_theme: explicit font overrides session option", {
  withr::with_options(list(highdir.font = "serif"), {
    gt <- gg_theme("classic", font = "mono")
    expect_equal(gt$theme$text$family, "mono")
  })
})

test_that("gg_theme: errors on unknown name string", {
  expect_error(gg_theme("neon_banana"), "Unknown gg_theme name")
})

test_that("gg_theme: errors on non-string non-theme input", {
  expect_error(gg_theme(42),     "must be a single theme name string")
  expect_error(gg_theme(TRUE),   "must be a single theme name string")
  expect_error(gg_theme(list()), "must be a single theme name string")
})

test_that("gg_theme: grey and gray are aliases — same $theme panel.background", {
  gt_grey <- gg_theme("grey")
  gt_gray <- gg_theme("gray")
  expect_equal(gt_grey$theme$panel.background$fill,
               gt_gray$theme$panel.background$fill)
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
# 4.  ggplot_engine integration — theme + colors + font applied to figure
# ══════════════════════════════════════════════════════════════════════════════

# Inspect structural theme properties that differ reliably between themes.
# theme_classic: element_blank panel grid, no panel fill
# theme_bw:      white panel background
# theme_minimal: transparent/NA panel background

test_that("ggplot_engine: theme_classic applied — panel grid is blank", {
  opts <- hd_opts(title = "t", gg_theme = "classic")
  fig  <- hd_make(spec, "column", opts, backend = "ggplot2")
  t    <- ggplot2::ggplot_build(fig)$plot$theme
  expect_true(inherits(t$panel.grid,       "element_blank") ||
              inherits(t$panel.grid.major, "element_blank"),
              label = "classic: no visible panel grid")
})

test_that("ggplot_engine: theme_bw applied — panel background is white", {
  opts <- hd_opts(title = "t", gg_theme = "bw")
  fig  <- hd_make(spec, "column", opts, backend = "ggplot2")
  t    <- ggplot2::ggplot_build(fig)$plot$theme
  expect_equal(t$panel.background$fill, "white",
               label = "bw: white panel background")
})

test_that("ggplot_engine: theme object in opts — base_size honoured", {
  obj  <- ggplot2::theme_bw(base_size = 18)
  opts <- hd_opts(title = "t", gg_theme = obj)
  fig  <- hd_make(spec, "column", opts, backend = "ggplot2")
  t    <- ggplot2::ggplot_build(fig)$plot$theme
  # base_size is stored in the top-level text element as absolute value
  expect_equal(t$text$size, 18)
})

test_that("ggplot_engine: session default used when opts$gg_theme is NULL", {
  withr::with_options(list(highdir.gg_theme = NULL), {
    opts <- hd_opts(title = "t")   # NULL -> classic fallback
    fig  <- hd_make(spec, "column", opts, backend = "ggplot2")
    t    <- ggplot2::ggplot_build(fig)$plot$theme
    expect_true(inherits(t$panel.grid,       "element_blank") ||
                inherits(t$panel.grid.major, "element_blank"),
                label = "classic fallback: no visible panel grid")
  })
})

test_that("ggplot_engine: opts gg_theme overrides session default", {
  withr::with_options(list(highdir.gg_theme = "classic"), {
    opts <- hd_opts(title = "t", gg_theme = "bw")
    fig  <- hd_make(spec, "column", opts, backend = "ggplot2")
    t    <- ggplot2::ggplot_build(fig)$plot$theme
    expect_equal(t$panel.background$fill, "white",
                 label = "per-figure bw overrides session classic")
  })
})

test_that("ggplot_engine: colors in opts applied to figure", {
  pal  <- c("#025169", "#7C145C")
  opts <- hd_opts(title = "t", colors = pal)
  fig  <- hd_make(spec, "column", opts, backend = "ggplot2")
  built <- ggplot2::ggplot_build(fig)
  # Colours appear in the data layer fills; check at least one matches palette
  fills <- unique(unlist(lapply(built$data, function(d) d$fill)))
  expect_true(any(fills %in% pal),
              label = "at least one fill matches the supplied palette")
})

test_that("ggplot_engine: font in opts applied to figure", {
  withr::with_options(list(highdir.font = "mono"), {
    opts <- hd_opts(title = "t", gg_theme = "classic")
    fig  <- hd_make(spec, "column", opts, backend = "ggplot2")
    t    <- ggplot2::ggplot_build(fig)$plot$theme
    expect_equal(t$text$family, "mono")
  })
})


# ══════════════════════════════════════════════════════════════════════════════
# 5.  hd_make() end-to-end — gg_theme does not affect highcharter backend
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
# 6.  font preserved across all theme names (ordering guard)
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
