test_that("hd_set_theme: sets and restores options", {
  withr::with_options(list(highdir.hc_theme = "default"), {
    prev <- hd_set_theme(hc_theme = "darkunica")
    expect_equal(getOption("highdir.hc_theme"), "darkunica")
    options(prev)
    expect_equal(getOption("highdir.hc_theme"), "default")
  })
})

test_that("hd_set_theme: sets colors option", {
  withr::with_options(list(highdir.colors = NULL), {
    hd_set_theme(colors = c("#AAAAAA", "#BBBBBB"))
    expect_equal(getOption("highdir.colors"), c("#AAAAAA", "#BBBBBB"))
  })
})

test_that("hd_theme: returns an hc_theme object for all built-in names", {
  themes <- c("default","smpl","economist","darkunica",
              "gridlight","bloom","flat","flatdark","ggplot2")
  for (nm in themes) {
    t <- hd_theme(nm)
    expect_true(inherits(t, "hc_theme"),
                label = paste("theme:", nm))
  }
})

test_that("hd_theme: errors on unknown name", {
  expect_error(hd_theme("neon_banana"), "Unknown theme")
})

test_that("hd_theme: colour override embedded in theme", {
  pal <- c("#FF0000", "#00FF00")
  t   <- hd_theme("default", colors = pal)
  expect_true(inherits(t, "hc_theme"))
  expect_true(any(unlist(t) %in% pal))
})

test_that("hd_add_js: errors when nothing supplied", {
  hc <- highcharter::highchart()
  expect_error(hd_add_js(hc), "Supply one of")
})

test_that("hd_add_js: injects inline code into chart", {
  hc  <- highcharter::highchart()
  hc2 <- hd_add_js(hc, code = "console.log('hi');")
  expect_true(is_highchart(hc2))
})

test_that("apply_gg_colors: no-op when no palette set", {
  withr::with_options(list(highdir.colors = NULL), {
    p  <- ggplot2::ggplot()
    p2 <- apply_gg_colors(p, NULL)
    expect_identical(p, p2)
  })
})
