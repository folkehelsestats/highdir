# tests/testthat/test-map.R ── Map geom tests

# ── Reference tables ──────────────────────────────────────────────────────────

test_that("no_counties: correct structure", {
  ct <- no_counties()
  expect_s3_class(ct, "data.frame")
  expect_equal(nrow(ct), 15)
  expect_named(ct, c("fylkesnummer", "name", "hc_key"))
})

test_that("no_counties: Oslo present and correct", {
  ct <- no_counties()
  oslo <- ct[ct$fylkesnummer == "03", ]
  expect_equal(nrow(oslo), 1)
  expect_equal(oslo$name,   "Oslo")
  expect_equal(oslo$hc_key, "no-03")
})

test_that("no_counties: all hc_keys match no-XX pattern", {
  ct <- no_counties()
  expect_true(all(grepl("^no-[0-9]{2}$", ct$hc_key)))
})

test_that("no_municipalities: correct structure", {
  mk <- no_municipalities()
  expect_s3_class(mk, "data.frame")
  expect_named(mk, c("kommunenummer", "name", "hc_key", "fylkesnummer"))
  expect_gt(nrow(mk), 10)
})

test_that("no_municipalities: major cities present", {
  mk <- no_municipalities()
  expect_true("Oslo"      %in% mk$name)
  expect_true("Bergen"    %in% mk$name)
  expect_true("Trondheim" %in% mk$name)
  expect_true("Stavanger" %in% mk$name)
  expect_true("Tromsø"    %in% mk$name)
})

test_that("no_municipalities: Oslo row is correct", {
  mk  <- no_municipalities()
  osl <- mk[mk$name == "Oslo", ]
  expect_equal(osl$kommunenummer, "0301")
  expect_equal(osl$fylkesnummer,  "03")
  expect_equal(osl$hc_key,        "no-03-0301")
})

test_that("no_municipalities: all hc_keys match no-XX-XXXX pattern", {
  mk <- no_municipalities()
  expect_true(all(grepl("^no-[0-9]{2}-[0-9]{4}$", mk$hc_key)))
})

test_that("no_municipalities: subset by county works", {
  mk <- subset(no_municipalities(), fylkesnummer == "46")
  expect_true(nrow(mk) > 0)
  expect_true("Bergen" %in% mk$name)
  expect_true(all(mk$fylkesnummer == "46"))
})

# ── Code normalisation helpers ────────────────────────────────────────────────

test_that(".norm_code: pads county integers", {
  expect_equal(.norm_code(3L,  "county"),       "03")
  expect_equal(.norm_code(11L, "county"),        "11")
  expect_equal(.norm_code(46L, "county"),        "46")
})

test_that(".norm_code: pads municipality integers", {
  expect_equal(.norm_code(301L,  "municipality"), "0301")
  expect_equal(.norm_code(4601L, "municipality"), "4601")
  expect_equal(.norm_code(5001L, "municipality"), "5001")
})

test_that(".norm_code: strips 'no-' county prefix", {
  expect_equal(.norm_code("no-03",      "county"),       "03")
  expect_equal(.norm_code("no-46",      "county"),       "46")
})

test_that(".norm_code: strips 'no-XX-' municipality prefix", {
  expect_equal(.norm_code("no-03-0301", "municipality"), "0301")
  expect_equal(.norm_code("no-46-4601", "municipality"), "4601")
})

test_that(".to_hc_key: county integers -> 'no-XX'", {
  expect_equal(.to_hc_key(3L,  "county"), "no-03")
  expect_equal(.to_hc_key(46L, "county"), "no-46")
})

test_that(".to_hc_key: municipality integers -> 'no-XX-XXXX'", {
  expect_equal(.to_hc_key(301L,  "municipality"), "no-03-0301")
  expect_equal(.to_hc_key(4601L, "municipality"), "no-46-4601")
  expect_equal(.to_hc_key(5001L, "municipality"), "no-50-5001")
})

test_that(".to_hc_key: vector input", {
  codes  <- c(3L, 11L, 46L, 50L)
  result <- .to_hc_key(codes, "county")
  expect_equal(result, c("no-03","no-11","no-46","no-50"))
})

test_that(".to_hc_key: handles pre-padded character codes", {
  expect_equal(.to_hc_key("0301", "municipality"), "no-03-0301")
  expect_equal(.to_hc_key("03",   "county"),        "no-03")
})

# ── Geom registration ─────────────────────────────────────────────────────────

test_that("'map' registered in list_geoms()", {
  expect_true("map" %in% list_geoms())
})

test_that("map geom has is_map_geom flag", {
  g <- get_geom("map")
  expect_true(isTRUE(g$is_map_geom))
})

test_that("map geom has gg and hc functions", {
  g <- get_geom("map")
  expect_true(is.function(g$ggplot_fun))
  expect_true(is.function(g$highcharter_fun))
})

# ── highcharter county map ────────────────────────────────────────────────────

# Minimal test dataset (integer fylkesnummer)
county_df <- data.frame(
  fylke = c(3L, 11L, 46L, 50L, 18L),
  rate  = c(42.5, 38.1, 55.2, 48.7, 39.0)
)

test_that("hd_make: HC county map returns highchart", {
  spec <- hd_spec(county_df, x = "fylke", y = "rate")
  opts <- hd_opts(title = "Helse per fylke")
  fig  <- hd_make(spec, "map", opts, level = "county")
  expect_true(is_highchart(fig))
})

test_that("hd_make: HC map with NULL opts uses defaults", {
  spec <- hd_spec(county_df, x = "fylke", y = "rate")
  expect_true(is_highchart(hd_make(spec, "map", opts = NULL)))
})

test_that("hd_make: HC county map with character codes", {
  df   <- data.frame(code = c("03","11","46","50"), val = c(10,20,30,40))
  spec <- hd_spec(df, x = "code", y = "val")
  expect_true(is_highchart(hd_make(spec, "map", level = "county")))
})

test_that("hd_make: HC county map from no_counties() data", {
  df   <- no_counties()
  set.seed(42)
  df$rate <- round(runif(nrow(df), 10, 80))
  spec <- hd_spec(df, x = "fylkesnummer", y = "rate")
  opts <- hd_opts(title = "Helseindikator per fylke",
                   subtitle = "Kilde: FHI 2024")
  fig  <- hd_make(spec, "map", opts, level = "county",
                  value_lab = "Rate per 100 000",
                  low_col   = "#EDF8FB",
                  high_col  = "#025169")
  expect_true(is_highchart(fig))
})

test_that("hd_make: HC map with custom colours", {
  spec <- hd_spec(county_df, x = "fylke", y = "rate")
  fig  <- hd_make(spec, "map", hd_opts(),
                  level    = "county",
                  low_col  = "#FFFFFF",
                  high_col = "#7C145C",
                  na_fill  = "#EEEEEE")
  expect_true(is_highchart(fig))
})

# ── highcharter municipality map ──────────────────────────────────────────────

test_that("hd_make: HC municipality map returns highchart", {
  df   <- no_municipalities()
  set.seed(7)
  df$rate <- round(runif(nrow(df), 20, 95))
  spec <- hd_spec(df, x = "kommunenummer", y = "rate")
  opts <- hd_opts(title = "Helse per kommune")
  fig  <- hd_make(spec, "map", opts, level = "municipality")
  expect_true(is_highchart(fig))
})

test_that("hd_make: HC municipality map from integer knr", {
  muni_df <- data.frame(
    knr  = c(301L, 1103L, 4601L, 5001L, 5401L),
    rate = c(42.5, 38.1, 55.2, 48.7, 60.1)
  )
  spec <- hd_spec(muni_df, x = "knr", y = "rate")
  fig  <- hd_make(spec, "map", hd_opts(title = "Kommunekart"),
                  level = "municipality")
  expect_true(is_highchart(fig))
})

# ── hd_save: map to file ─────────────────────────────────────────────────────

test_that("hd_save: HC map to HTML", {
  spec <- hd_spec(county_df, x = "fylke", y = "rate")
  fig  <- hd_make(spec, "map", hd_opts(title = "Lagre test"))
  f    <- tempfile(fileext = ".html")
  withr::defer(unlink(f))
  hd_save(fig, f)
  expect_true(file.exists(f))
  expect_gt(file.size(f), 1000)
})

test_that("hd_save: HC map to JSON", {
  spec <- hd_spec(county_df, x = "fylke", y = "rate")
  fig  <- hd_make(spec, "map")
  f    <- tempfile(fileext = ".json")
  withr::defer(unlink(f))
  hd_save(fig, f)
  expect_true(file.exists(f))
  expect_type(jsonlite::read_json(f), "list")
})

# ── ggplot2 map backend ───────────────────────────────────────────────────────

test_that("hd_make: gg county map returns ggplot (skip if no sf or offline)", {
  skip_if_not_installed("sf")
  skip_if_offline()
  spec <- hd_spec(county_df, x = "fylke", y = "rate")
  opts <- hd_opts(title = "Helse per fylke (ggplot2)")
  fig  <- hd_make(spec, "map", opts, backend = "ggplot2", level = "county")
  expect_true(is_ggplot(fig))
})

test_that("gg_map errors informatively without sf", {
  skip_if(requireNamespace("sf", quietly = TRUE), "sf installed")
  spec <- hd_spec(county_df, x = "fylke", y = "rate")
  expect_error(
    hd_make(spec, "map", hd_opts(), backend = "ggplot2"),
    "sf"
  )
})

# ── Error handling ────────────────────────────────────────────────────────────

test_that("hd_make: map rejects non-hd_spec", {
  expect_error(hd_make(list(), "map"), "hd_spec")
})
