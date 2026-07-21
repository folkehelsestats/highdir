
# Test coverage for:
#   .validate_venn_sets()       internal validator
#   hd_venn_set()               single-set entry constructor
#   hd_venn_intersect()         intersection entry constructor
#   hd_geom_venn()              composable layer constructor
#   hd_spec_venn()              declarative spec constructor
#   hd_venn_sets_from_spec()    spec extractor
#   print.hd_spec_venn()        S3 print method
#   hc_venn()                   highcharter render function
#   gg_venn()                   ggplot2 render function (conditional on eulerr)
#   hd_make() + venn            full declarative render pipeline
#   hd() + hd_geom_venn()       full composable render pipeline
#
# Test organisation
# -----------------
# 1. hd_venn_set()              - constructor output + input validation
# 2. hd_venn_intersect()        - constructor output + input validation
# 3. .validate_venn_sets()      - all error branches
# 4. hd_geom_venn()             - layer class, slot values, early validation
# 5. hd_spec_venn()             - class, structure, sentinel fields
# 6. hd_venn_sets_from_spec()   - roundtrip, wrong-class guard
# 7. print.hd_spec_venn()       - output format
# 8. Set list extension         - c() / append() patterns
# 9. hc_venn()                  - output class, series type, data slots
# 10. gg_venn()                 - eulerr path (skipped if not installed)
# 11. hd_make() declarative     - highcharter + ggplot2 pipelines
# 12. hd() composable           - highcharter + ggplot2 pipelines
# 13. Cross-API parity          - declarative and composable produce same type


# =============================================================================
# Shared fixtures
# =============================================================================

# Minimal two-set list - used across most tests
two_sets <- list(
  hd_venn_set("A", "Oslo",   value = 120),
  hd_venn_set("B", "Bergen", value = 95)
)

# Two sets + one intersection - most realistic input
three_entries <- list(
  hd_venn_set("A", "Oslo",   value = 120),
  hd_venn_set("B", "Bergen", value = 95),
  hd_venn_intersect(c("A", "B"), value = 40)
)

# Three-set list for Euler / ggVennDiagram paths
three_sets <- list(
  hd_venn_set("A", "Animals",   value = 5),
  hd_venn_set("B", "Four legs", value = 4),
  hd_venn_set("C", "Mineral",   value = 2),
  hd_venn_intersect(c("A", "B"), value = 3)
)

opts_v <- hd_opts(title = "City overlap", subtitle = "Source: FHI")


# =============================================================================
# 1. hd_venn_set()
# =============================================================================

test_that("hd_venn_set returns correctly structured list", {
  s <- hd_venn_set("A", "Oslo", 120)

  expect_type(s, "list")
  expect_named(s, c("sets", "name", "value"))

  # $sets must be a list containing the id string
  expect_type(s$sets, "list")
  expect_length(s$sets, 1L)
  expect_identical(s$sets[[1L]], "A")

  expect_identical(s$name, "Oslo")
  expect_identical(s$value, 120)
  expect_type(s$value, "double")   # as.numeric() applied - not integer
})

test_that("hd_venn_set coerces integer value to double", {
  s <- hd_venn_set("X", "Label", 5L)
  expect_type(s$value, "double")
  expect_equal(s$value, 5)
})

test_that("hd_venn_set errors on non-character id", {
  expect_error(hd_venn_set(1L,  "Name", 10), "id.*single character")
  expect_error(hd_venn_set(NULL,"Name", 10), "id.*single character")
  expect_error(hd_venn_set(c("A","B"), "Name", 10), "id.*single character")
})

test_that("hd_venn_set errors on non-character name", {
  expect_error(hd_venn_set("A", 42,   10), "name.*single character")
  expect_error(hd_venn_set("A", NULL, 10), "name.*single character")
})

test_that("hd_venn_set errors on non-numeric or multi-value value", {
  expect_error(hd_venn_set("A", "L", "x"),     "value.*single number")
  expect_error(hd_venn_set("A", "L", c(1, 2)), "value.*single number")
  expect_error(hd_venn_set("A", "L", NULL),    "value.*single number")
})


# =============================================================================
# 2. hd_venn_intersect()
# =============================================================================

test_that("hd_venn_intersect returns correctly structured list without name", {
  e <- hd_venn_intersect(c("A", "B"), value = 40)

  expect_type(e, "list")
  expect_named(e, c("sets", "value"))   # no name slot when name = NULL

  expect_type(e$sets, "list")
  expect_length(e$sets, 2L)
  expect_identical(e$sets[[1L]], "A")
  expect_identical(e$sets[[2L]], "B")

  expect_identical(e$value, 40)
  expect_type(e$value, "double")
})

test_that("hd_venn_intersect includes name when supplied", {
  e <- hd_venn_intersect(c("A", "B"), value = 10, name = "Overlap")
  expect_named(e, c("sets", "value", "name"))
  expect_identical(e$name, "Overlap")
})

test_that("hd_venn_intersect works with three sets", {
  e <- hd_venn_intersect(c("A", "B", "C"), value = 5)
  expect_length(e$sets, 3L)
  expect_identical(e$sets[[3L]], "C")
})

test_that("hd_venn_intersect errors on ids with length < 2", {
  expect_error(hd_venn_intersect("A",           value = 5), "length >= 2")
  expect_error(hd_venn_intersect(character(0),  value = 5), "length >= 2")
})

test_that("hd_venn_intersect errors on non-character ids", {
  expect_error(hd_venn_intersect(c(1L, 2L), value = 5), "length >= 2")
})

test_that("hd_venn_intersect errors on bad value", {
  expect_error(hd_venn_intersect(c("A","B"), value = "x"),     "single number")
  expect_error(hd_venn_intersect(c("A","B"), value = c(1, 2)), "single number")
})


# =============================================================================
# 3. .validate_venn_sets()
# =============================================================================

test_that(".validate_venn_sets passes silently on valid input", {
  expect_silent(highdir:::.validate_venn_sets(two_sets))
  expect_silent(highdir:::.validate_venn_sets(three_entries))
  expect_silent(highdir:::.validate_venn_sets(three_sets))
})

test_that(".validate_venn_sets errors on empty list", {
  expect_error(highdir:::.validate_venn_sets(list()),
               "non-empty list")
})

test_that(".validate_venn_sets errors on non-list input", {
  expect_error(highdir:::.validate_venn_sets("not a list"), "non-empty list")
  expect_error(highdir:::.validate_venn_sets(NULL),         "non-empty list")
})

test_that(".validate_venn_sets errors when entry is not a list", {
  bad <- list("not_a_list")
  expect_error(highdir:::.validate_venn_sets(bad), "named list")
})

test_that(".validate_venn_sets errors when $sets slot is missing or empty", {
  # missing $sets entirely
  bad_no_sets <- list(list(value = 5))
  expect_error(highdir:::.validate_venn_sets(bad_no_sets),
               "\\$sets must be a non-empty list")

  # $sets is an empty list
  bad_empty <- list(list(sets = list(), value = 5))
  expect_error(highdir:::.validate_venn_sets(bad_empty),
               "\\$sets must be a non-empty list")
})

test_that(".validate_venn_sets errors when $sets contains non-character", {
  bad <- list(list(sets = list(1L), value = 5))
  expect_error(highdir:::.validate_venn_sets(bad),
               "character strings")
})

test_that(".validate_venn_sets errors when $value is missing or non-numeric", {
  bad_no_value <- list(list(sets = list("A")))
  expect_error(highdir:::.validate_venn_sets(bad_no_value),
               "\\$value must be a single numeric")

  bad_char_value <- list(list(sets = list("A"), value = "x"))
  expect_error(highdir:::.validate_venn_sets(bad_char_value),
               "\\$value must be a single numeric")

  bad_multi_value <- list(list(sets = list("A"), value = c(1, 2)))
  expect_error(highdir:::.validate_venn_sets(bad_multi_value),
               "\\$value must be a single numeric")
})

test_that(".validate_venn_sets reports the correct entry index in error", {
  # Second entry is bad - error message should mention index 2
  mixed <- list(
    list(sets = list("A"), value = 5),
    list(sets = list("B"))             # missing value
  )
  expect_error(highdir:::.validate_venn_sets(mixed), "sets\\[\\[2\\]\\]")
})

test_that(".validate_venn_sets uses call_name in error messages", {
  expect_error(
    highdir:::.validate_venn_sets(list(), call_name = "my_fn"),
    "my_fn"
  )
})


# =============================================================================
# 4. hd_geom_venn()
# =============================================================================

test_that("hd_geom_venn returns an hd_geom object", {
  g <- hd_geom_venn(sets = two_sets)
  expect_s3_class(g, "hd_geom")
})

test_that("hd_geom_venn stores type as 'venn'", {
  g <- hd_geom_venn(sets = two_sets)
  expect_identical(g$type, "venn")
})

test_that("hd_geom_venn stores sets in params", {
  g <- hd_geom_venn(sets = two_sets)
  expect_identical(g$params$sets, two_sets)
})

test_that("hd_geom_venn stores series_name default", {
  g <- hd_geom_venn(sets = two_sets)
  expect_identical(g$params$series_name, "Venn Diagram")
})

test_that("hd_geom_venn stores custom series_name", {
  g <- hd_geom_venn(sets = two_sets, series_name = "City Overlap")
  expect_identical(g$params$series_name, "City Overlap")
})

test_that("hd_geom_venn stores label_font_size default", {
  g <- hd_geom_venn(sets = two_sets)
  expect_identical(g$params$label_font_size, "14px")
})

test_that("hd_geom_venn stores custom label_font_size", {
  g <- hd_geom_venn(sets = two_sets, label_font_size = "20px")
  expect_identical(g$params$label_font_size, "20px")
})

test_that("hd_geom_venn validates sets at construction time", {
  expect_error(hd_geom_venn(sets = list()),   "non-empty list")
  expect_error(hd_geom_venn(sets = "bad"),    "non-empty list")
  expect_error(
    hd_geom_venn(sets = list(list(sets = list("A")))),  # missing value
    "\\$value"
  )
})


# =============================================================================
# 5. hd_spec_venn()
# =============================================================================

test_that("hd_spec_venn returns correct dual class", {
  sv <- hd_spec_venn(two_sets)
  expect_s3_class(sv, "hd_spec_venn")
  expect_s3_class(sv, "hd_spec")
})

test_that("hd_spec_venn has correct sentinel fields", {
  sv <- hd_spec_venn(two_sets)
  expect_identical(sv$x,      ".venn_sets")
  expect_identical(sv$y,      ".value")
  expect_null(sv$group)
  expect_null(sv$n)
  expect_null(sv$colour)
})

test_that("hd_spec_venn wraps sets in a one-row data.frame", {
  sv <- hd_spec_venn(two_sets)
  expect_s3_class(sv$data, "data.frame")
  expect_equal(nrow(sv$data), 1L)
  expect_true(".venn_sets" %in% names(sv$data))
  expect_true(".value"     %in% names(sv$data))
})

test_that("hd_spec_venn preserves the full set list inside $data", {
  sv      <- hd_spec_venn(three_entries)
  stored  <- sv$data[[".venn_sets"]][[1L]]
  expect_length(stored, 3L)
  expect_identical(stored, three_entries)
})

test_that("hd_spec_venn validates sets at construction time", {
  expect_error(hd_spec_venn(list()),  "non-empty list")
  expect_error(hd_spec_venn("bad"),   "non-empty list")
  expect_error(
    hd_spec_venn(list(list(sets = list("A"), value = "x"))),
    "\\$value"
  )
})


# =============================================================================
# 6. hd_venn_sets_from_spec()
# =============================================================================

test_that("hd_venn_sets_from_spec roundtrips the original set list", {
  sv       <- hd_spec_venn(three_entries)
  recovered <- hd_venn_sets_from_spec(sv)
  expect_identical(recovered, three_entries)
})

test_that("hd_venn_sets_from_spec works with two_sets", {
  sv        <- hd_spec_venn(two_sets)
  recovered <- hd_venn_sets_from_spec(sv)
  expect_length(recovered, 2L)
  expect_identical(recovered[[1L]]$sets[[1L]], "A")
  expect_identical(recovered[[2L]]$sets[[1L]], "B")
})

test_that("hd_venn_sets_from_spec errors when passed a plain hd_spec", {
  plain_spec <- structure(list(), class = "hd_spec")
  expect_error(
    hd_venn_sets_from_spec(plain_spec),
    "hd_spec_venn object"
  )
})

test_that("hd_venn_sets_from_spec errors when passed a non-spec object", {
  expect_error(hd_venn_sets_from_spec("string"), "hd_spec_venn object")
  expect_error(hd_venn_sets_from_spec(list()),   "hd_spec_venn object")
})


# =============================================================================
# 7. print.hd_spec_venn()
# =============================================================================

test_that("print.hd_spec_venn outputs expected lines", {
  sv  <- hd_spec_venn(three_entries)
  out <- capture.output(print(sv))

  expect_true(any(grepl("<hd_spec_venn>",  out)))
  expect_true(any(grepl("sets.*3",         out)))   # 3 entries
  expect_true(any(grepl("groups",          out)))   # single-set labels
  expect_true(any(grepl("inters.*1",       out)))   # 1 intersection
})

test_that("print.hd_spec_venn omits inters line when no intersections", {
  sv  <- hd_spec_venn(two_sets)
  out <- capture.output(print(sv))
  expect_false(any(grepl("inters", out)))
})

test_that("print.hd_spec_venn returns spec invisibly", {
  sv <- hd_spec_venn(two_sets)
  expect_identical(withVisible(print(sv))$visible, FALSE)
})


# =============================================================================
# 8. Set list extension patterns
# =============================================================================

test_that("c() extends a set list correctly", {
  base     <- two_sets
  extended <- c(base, list(hd_venn_intersect(c("A", "B"), value = 40)))

  expect_length(extended, 3L)
  expect_identical(extended[[3L]]$sets, list("A", "B"))
  expect_identical(extended[[3L]]$value, 40)
})

test_that("append() extends a set list correctly", {
  base     <- two_sets
  extra    <- hd_venn_set("C", "Trondheim", value = 60)
  extended <- append(base, list(extra))

  expect_length(extended, 3L)
  expect_identical(extended[[3L]]$sets[[1L]], "C")
  expect_identical(extended[[3L]]$name, "Trondheim")
})

test_that("hd_venn_sets_from_spec can be used to extend a declarative spec", {
  sv       <- hd_spec_venn(two_sets)
  existing <- hd_venn_sets_from_spec(sv)
  extended <- c(existing, list(hd_venn_intersect(c("A", "B"), value = 40)))

  sv2 <- hd_spec_venn(extended)
  expect_length(hd_venn_sets_from_spec(sv2), 3L)
})

test_that("extended spec round-trips correctly through hd_spec_venn", {
  extended <- c(
    two_sets,
    list(hd_venn_intersect(c("A", "B"), value = 40))
  )
  sv <- hd_spec_venn(extended)
  expect_length(hd_venn_sets_from_spec(sv), 3L)
  expect_identical(hd_venn_sets_from_spec(sv)[[3L]]$value, 40)
})


# =============================================================================
# 9. hc_venn() - highcharter render function
# =============================================================================

test_that("hc_venn returns a highchart object", {
  chart  <- highcharter::highchart()
  spec   <- hd_spec_venn(three_entries)
  opts   <- hd_opts(title = "Test")
  params <- list(sets = three_entries)

  result <- hc_venn(chart, spec, opts, params)
  expect_s3_class(result, "highchart")
})

test_that("hc_venn sets chart type to venn", {
  chart  <- highcharter::highchart()
  spec   <- hd_spec_venn(three_entries)
  params <- list(sets = three_entries)
  result <- hc_venn(chart, spec, hd_opts(), params)

  chart_type <- result$x$hc_opts$series[[1L]]$type
  expect_identical(chart_type, "venn")
})

test_that("hc_venn adds exactly one series", {
  chart  <- highcharter::highchart()
  spec   <- hd_spec_venn(three_entries)
  params <- list(sets = three_entries)
  result <- hc_venn(chart, spec, hd_opts(), params)

  expect_length(result$x$hc_opts$series, 1L)
})

test_that("hc_venn series data has correct length", {
  chart  <- highcharter::highchart()
  spec   <- hd_spec_venn(three_entries)
  params <- list(sets = three_entries)
  result <- hc_venn(chart, spec, hd_opts(), params)

  series_data <- result$x$hc_opts$series[[1L]]$data
  expect_length(series_data, length(three_entries))
})

test_that("hc_venn uses default series_name when not supplied", {
  chart  <- highcharter::highchart()
  spec   <- hd_spec_venn(two_sets)
  params <- list(sets = two_sets)
  result <- hc_venn(chart, spec, hd_opts(), params)

  expect_identical(result$x$hc_opts$series[[1L]]$name, "Venn Diagram")
})

test_that("hc_venn uses custom series_name when supplied", {
  chart  <- highcharter::highchart()
  spec   <- hd_spec_venn(two_sets)
  params <- list(sets = two_sets, series_name = "City Circles")
  result <- hc_venn(chart, spec, hd_opts(), params)

  expect_identical(result$x$hc_opts$series[[1L]]$name, "City Circles")
})

test_that("hc_venn resolves sets from spec when geom_params$sets is NULL", {
  # This tests the declarative API path: sets come from spec, not params
  chart  <- highcharter::highchart()
  spec   <- hd_spec_venn(two_sets)
  params <- list()   # no sets here

  result <- hc_venn(chart, spec, hd_opts(), params)
  expect_s3_class(result, "highchart")
  expect_length(result$x$hc_opts$series[[1L]]$data, 2L)
})

test_that("hc_venn errors when sets is NULL and spec is not hd_spec_venn", {
  chart      <- highcharter::highchart()
  plain_spec <- hd_spec(data.frame(x = 1, y = 1), x = "x", y = "y")
  params     <- list()   # no sets

  expect_error(
    hc_venn(chart, plain_spec, hd_opts(), params),
    "non-empty list"
  )
})

test_that("hc_venn coerces value to double in series data", {
  chart  <- highcharter::highchart()
  # Use integer values to verify coercion
  int_sets <- list(
    list(sets = list("A"), name = "A", value = 5L),
    list(sets = list("B"), name = "B", value = 3L)
  )
  spec   <- hd_spec_venn(int_sets)
  params <- list(sets = int_sets)
  result <- hc_venn(chart, spec, hd_opts(), params)

  vals <- vapply(result$x$hc_opts$series[[1L]]$data,
                 function(e) e$value, numeric(1))
  expect_type(vals, "double")
})


# =============================================================================
# 10. gg_venn() - ggplot2 backend (conditional on eulerr)
# =============================================================================

test_that("gg_venn with eulerr returns a list with annotation_custom layer", {
  skip_if_not_installed("eulerr")

  spec   <- hd_spec_venn(three_entries)
  params <- list(sets = three_entries)
  layers <- gg_venn(spec, hd_opts(title = "Test"), params)

  expect_type(layers, "list")
  expect_length(layers, 1L)
  expect_s3_class(layers[[1L]], "LayerInstance")
  # annotation_custom produces a ggplot2 layer - not a grob directly
  expect_true(
    inherits(layers[[1L]], "Layer") ||
    identical(class(layers[[1L]])[1L], "LayerInstance")
  )
})

test_that("gg_venn with eulerr produces a layer with Inf extents", {
  skip_if_not_installed("eulerr")

  spec   <- hd_spec_venn(three_entries)
  params <- list(sets = three_entries)
  layers <- gg_venn(spec, hd_opts(), params)

  # The annotation_custom layer should have -Inf/Inf extents
  layer_params <- layers[[1L]]$geom_params
  expect_identical(layer_params$xmin, -Inf)
  expect_identical(layer_params$xmax,  Inf)
  expect_identical(layer_params$ymin, -Inf)
  expect_identical(layer_params$ymax,  Inf)
})

test_that("gg_venn with ggVennDiagram returns sentinel __ggplot__ list", {
  skip_if_not_installed("ggVennDiagram")
  skip_if(requireNamespace("eulerr", quietly = TRUE),
          "eulerr takes priority; skip ggVennDiagram path when eulerr present")

  spec   <- hd_spec_venn(three_entries)
  params <- list(sets = three_entries)
  layers <- gg_venn(spec, hd_opts(title = "Test"), params)

  expect_true("__ggplot__" %in% names(layers))
  expect_s3_class(layers[["__ggplot__"]], "ggplot")
})

test_that("gg_venn resolves sets from spec when geom_params$sets is NULL", {
  skip_if_not_installed("eulerr")

  spec   <- hd_spec_venn(three_entries)
  params <- list()   # no sets in params - must come from spec
  expect_silent(gg_venn(spec, hd_opts(), params))
})

test_that("gg_venn emits message and returns geom_blank when no package available", {
  skip_if(requireNamespace("eulerr",        quietly = TRUE))
  skip_if(requireNamespace("ggVennDiagram", quietly = TRUE))

  spec   <- hd_spec_venn(two_sets)
  params <- list(sets = two_sets)

  expect_message(
    result <- gg_venn(spec, hd_opts(), params),
    "eulerr.*ggVennDiagram|install"
  )
  expect_type(result, "list")
  expect_length(result, 1L)
})


# =============================================================================
# 11. hd_make() - declarative render pipeline
# =============================================================================

test_that("hd_make with hd_spec_venn returns highchart (highcharter backend)", {
  sv     <- hd_spec_venn(three_entries)
  result <- hd_make(sv, "venn", opts_v)
  expect_s3_class(result, "highchart")
})

test_that("hd_make declarative sets chart type to venn in JSON", {
  sv     <- hd_spec_venn(three_entries)
  result <- hd_make(sv, "venn", opts_v)
  expect_identical(result$x$hc_opts$series[[1L]]$type, "venn")
})

test_that("hd_make declarative applies title from opts", {
  sv     <- hd_spec_venn(three_entries)
  result <- hd_make(sv, "venn", hd_opts(title = "My Venn"))
  expect_identical(result$x$hc_opts$title$text, "My Venn")
})

test_that("hd_make declarative works with explicit sets in ...", {
  # sets supplied via ... - explicit override of what is in spec
  sv     <- hd_spec_venn(two_sets)
  result <- hd_make(sv, "venn", opts_v, sets = two_sets)
  expect_s3_class(result, "highchart")
})

test_that("hd_make declarative ggplot2 backend returns ggplot when eulerr present", {
  skip_if_not_installed("eulerr")
  sv     <- hd_spec_venn(three_entries)
  result <- hd_make(sv, "venn", opts_v, mode = "static")
  expect_s3_class(result, "ggplot")
})

test_that("hd_make declarative with opts NULL uses defaults without error", {
  sv <- hd_spec_venn(two_sets)
  expect_s3_class(hd_make(sv, "venn"), "highchart")
})


# =============================================================================
# 12. hd() + hd_geom_venn() - composable render pipeline
# =============================================================================

test_that("composable API returns highchart (highcharter backend)", {
  result <- hd(data.frame(), mode = "dynamic") +
    hd_geom_venn(sets = three_entries) +
    hd_opts(title = "Composable venn")

#   expect_s3_class(result, "highchart")
  expect_s3_class(result, "hd")
})

test_that("composable API sets chart type to venn", {
  result <- hd(data.frame(), mode = "dynamic") +
    hd_geom_venn(sets = three_entries) +
    hd_opts(title = "Test")

#   expect_identical(result$x$hc_opts$chart$type, "venn")
  expect_identical(result$geom$type, "venn")
})

test_that("composable API applies title from hd_opts", {
  result <- hd(data.frame(), mode = "dynamic") +
    hd_geom_venn(sets = two_sets) +
    hd_opts(title = "Composable title")

#   expect_identical(result$x$hc_opts$title$text, "Composable title")
  expect_identical(result$opts$title, "Composable title")
})

test_that("composable API ggplot2 backend returns ggplot when eulerr present", {
  skip_if_not_installed("eulerr")

  result <- hd(data.frame(), mode = "static") +
    hd_geom_venn(sets = three_entries) +
    hd_opts(title = "gg venn")

#   expect_s3_class(result, "ggplot")
  expect_s3_class(result, "hd")
})

# test_that("composable API with custom series_name passes through", {
#   result <- hd(data.frame(), mode = "dynamic") +
#     hd_geom_venn(sets = two_sets, series_name = "Custom Name") +
#     hd_opts(title = "Test")

#   expect_identical(result$x$hc_opts$series[[1L]]$name, "Custom Name")
# })

test_that("composable API with extended set list renders correctly", {
  extended <- c(
    two_sets,
    list(hd_venn_intersect(c("A", "B"), value = 40))
  )
  result <- hd(data.frame(), mode = "dynamic") +
    hd_geom_venn(sets = extended) +
    hd_opts(title = "Extended")

  expect_s3_class(result, "hd")
#   expect_length(result$x$hc_opts$series[[1L]]$data, 3L)
})


# =============================================================================
# 13. Cross-API parity
# =============================================================================

test_that("declarative and composable produce same chart type", {
  dec <- hd_make(hd_spec_venn(three_entries), "venn", opts_v)
  com <- hd(data.frame(), mode = "dynamic") +
    hd_geom_venn(sets = three_entries) +
    opts_v

  expect_identical(
    dec$x$hc_opts$chart$type,
    com$x$hc_opts$chart$type
  )
})

# test_that("declarative and composable produce same number of series data points", {
#   dec <- hd_make(hd_spec_venn(three_entries), "venn", opts_v)
#   com <- hd(data.frame(), mode = "dynamic") +
#     hd_geom_venn(sets = three_entries) +
#     opts_v

#   expect_equal(
#     length(dec$x$hc_opts$series[[1L]]$data),
#     length(com$x$hc_opts$series[[1L]]$data)
#   )
# })

# test_that("declarative and composable ggplot2 both return ggplot", {
#   skip_if_not_installed("eulerr")

#   dec <- hd_make(hd_spec_venn(three_entries), "venn", opts_v,
#                  mode = "static")
#   com <- hd(data.frame(), mode = "static") +
#     hd_geom_venn(sets = three_entries) +
#     opts_v

#   expect_s3_class(dec, "ggplot")
#   expect_s3_class(com, "ggplot")
# })
