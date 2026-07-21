# tests/testthat/test-mode-deprecation.R
# Temporary testin for funcitons that are deprecated and will be removed in the future

test_that("normalize_mode accepts new values", {
  expect_no_warning(
    expect_identical(
      normalize_mode("dynamic"),
      "dynamic"
    )
  )

  expect_no_warning(
    expect_identical(
      normalize_mode("static"),
      "static"
    )
  )
})

test_that("normalize_mode rejects invalid values", {
  expect_snapshot(
    error = TRUE,
    normalize_mode("foobar")
  )
})

test_that("hd defaults to dynamic mode", {
  obj <- hd()

  expect_s3_class(obj, "hd")

  expect_identical(
    obj$mode,
    "dynamic"
  )
})

test_that("hd accepts new mode values", {
  expect_no_warning({
    obj <- hd(mode = "dynamic")
  })

  expect_identical(
    obj$mode,
    "dynamic"
  )

  expect_no_warning({
    obj <- hd(mode = "static")
  })

  expect_identical(
    obj$mode,
    "static"
  )
})

test_that("hd translates deprecated backend values", {
  obj <- suppressWarnings(
    hd(backend = "highcharter")
  )

  expect_identical(
    obj$mode,
    "dynamic"
  )

  obj <- suppressWarnings(
    hd(backend = "ggplot2")
  )

  expect_identical(
    obj$mode,
    "static"
  )
})

test_that("mode and backend cannot both be supplied", {

  expect_error(
    hd(
      mode = "dynamic",
      backend = "highcharter"
    ),
    "either `mode` or `backend`"
  )
})


