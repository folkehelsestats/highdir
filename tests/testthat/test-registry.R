# tests/testthat/test-registry.R
#
# Covers every public and internal function in R/registry.R:
#
#   Backend registry   — register_backend(), get_backend(), list_backends()
#   Geometry registry  — register_geom(), .get_geom(), list_geoms()
#   Arg validation     — register_geom() structure checks (optional_args)
#   Discoverability    — geom_args()
#   validate_geom_args — in validate.R, driven by required_args named-list
#
# REQUIRED_ARGS STRUCTURE (current design):
#   required_args is a named list where each entry is list(default, desc),
#   matching the optional_args structure.  names(required_args) gives the
#   arg names used by validate_geom_args() and mod_data's req_args reactive.
#
# INTERNAL FUNCTIONS:
#   .get_geom() and geom_args() are not exported; accessed via highdir:::.

# -- Helpers ------------------------------------------------------------------

# Minimal dummy functions satisfying the engine contract
.dummy_gg <- function(spec, opts, geom_params, ...) list()
.dummy_hc <- function(chart, spec, opts, geom_params, ...) chart

# Minimal valid optional_args entry
.opt <- function(default = TRUE, desc = "A test arg") {
  list(default = default, desc = desc)
}

# Minimal valid required_args entry
.req <- function(desc = "A required column") {
  list(default = NULL, desc = desc)
}


# =============================================================================
# 1.  Backend registry
# =============================================================================

test_that("built-in backends are registered at package load", {
  expect_true("static"     %in% list_backends())
  expect_true("dynamic" %in% list_backends())
})

test_that("list_backends returns a sorted character vector", {
  b <- list_backends()
  expect_type(b, "character")
  expect_equal(b, sort(b))
})

test_that("register_backend: round-trip with get_backend", {
  eng <- function(spec, geom, opts, geom_params, use_js, ...) NULL
  on.exit(rm("test_engine", envir = highdir:::.backend_registry), add = TRUE)
  register_backend("test_engine", eng)

  expect_true("test_engine" %in% list_backends())
  expect_identical(get_backend("test_engine"), eng)
})

test_that("register_backend: overwrites an existing backend silently", {
  eng1 <- function(...) "v1"
  eng2 <- function(...) "v2"
  on.exit(rm("overwrite_test", envir = highdir:::.backend_registry), add = TRUE)
  register_backend("overwrite_test", eng1)

  register_backend("overwrite_test", eng2)
  expect_identical(get_backend("overwrite_test"), eng2)
})

test_that("register_backend: returns name invisibly", {
  eng    <- function(...) NULL
  on.exit(rm("invisible_test", envir = highdir:::.backend_registry), add = TRUE)
  result <- register_backend("invisible_test", eng)

  expect_equal(result, "invisible_test")
})

test_that("register_backend: rejects non-function engine", {
  expect_error(register_backend("bad", "a string"), "function")
  expect_error(register_backend("bad", 42),         "function")
  expect_error(register_backend("bad", NULL),        "function")
  expect_error(register_backend("bad", list()),      "function")
})

test_that("register_backend: rejects empty name", {
  expect_error(register_backend("",  function(...) NULL), "non-empty")
  expect_error(register_backend(NULL, function(...) NULL), "non-empty")
})

test_that("get_backend: returns NULL for unknown backend", {
  expect_null(get_backend("nonexistent_backend_xyz"))
})


# =============================================================================
# 2.  Geometry registry -- registration and retrieval
# =============================================================================

test_that("built-in geoms are registered at package load", {
  g <- list_geoms()
  expect_true(all(c("column", "line", "scatter",
                    "arearange", "pie", "ranked_bar") %in% g))
})

test_that("list_geoms returns a sorted character vector", {
  g <- list_geoms()
  expect_type(g, "character")
  expect_equal(g, sort(g))
})

test_that("register_geom / .get_geom: round-trip stores all fields", {
  on.exit(rm("rt_geom", envir = highdir:::.geom_registry), add = TRUE)
  register_geom("rt_geom",
    ggplot_fun      = .dummy_gg,
    highcharter_fun = .dummy_hc,
    required_args   = list(foo = .req("A required foo")),
    optional_args   = list(bar = .opt(42L, "Bar radius")),
    skip_base_fig   = FALSE
  )

  g <- highdir:::.get_geom("rt_geom")

  expect_equal(g$name, "rt_geom")
  expect_true(is.function(g$ggplot_fun))
  expect_true(is.function(g$highcharter_fun))
  expect_false(isTRUE(g$skip_base_fig))

  # required_args: named list with default + desc
  expect_true("foo" %in% names(g$required_args))
  expect_null(g$required_args$foo$default)
  expect_equal(g$required_args$foo$desc, "A required foo")

  # optional_args: named list with default + desc
  expect_true("bar" %in% names(g$optional_args))
  expect_equal(g$optional_args$bar$default, 42L)
  expect_equal(g$optional_args$bar$desc,    "Bar radius")
})

test_that("register_geom: NULL functions are accepted", {
  on.exit(rm("null_fns_geom", envir = highdir:::.geom_registry), add = TRUE)
  register_geom("null_fns_geom")

  g <- highdir:::.get_geom("null_fns_geom")
  expect_null(g$ggplot_fun)
  expect_null(g$highcharter_fun)
})

test_that("register_geom: skip_base_fig = TRUE stored correctly", {
  on.exit(rm("map_test_geom", envir = highdir:::.geom_registry), add = TRUE)
  register_geom("map_test_geom", skip_base_fig = TRUE)

  expect_true(isTRUE(highdir:::.get_geom("map_test_geom")$skip_base_fig))
})

test_that("register_geom: returns name invisibly", {
  on.exit(rm("invis_geom", envir = highdir:::.geom_registry), add = TRUE)
  result <- register_geom("invis_geom")

  expect_equal(result, "invis_geom")
})

test_that("register_geom: overwrites an existing geom silently", {
  on.exit(rm("overwrite_geom", envir = highdir:::.geom_registry), add = TRUE)
  register_geom("overwrite_geom",
    optional_args = list(x = .opt(1L, "first")))

  register_geom("overwrite_geom",
    optional_args = list(x = .opt(2L, "second")))

  g <- highdir:::.get_geom("overwrite_geom")
  expect_equal(g$optional_args$x$default, 2L)
})

test_that(".get_geom: returns NULL for unknown geom", {
  expect_null(highdir:::.get_geom("nonexistent_geom_xyz"))
})

# test_that("register_geom: rejects empty or invalid name", {
#   expect_error(register_geom(""))
#   expect_error(register_geom(NULL))
# })


# =============================================================================
# 3.  register_geom() -- optional_args structure validation
# =============================================================================

test_that("register_geom: rejects unnamed optional_args", {
  expect_error(
    register_geom("bad_oa",
      optional_args = list(.opt(1, "ok"), .opt(2, "unnamed"))),
    "fully named"
  )
})

test_that("register_geom: rejects optional_args with empty name", {
  # list("" = ...) is a parse error in R, so build it dynamically at runtime
  oa_empty_key <- setNames(list(.opt(1, "empty key")), "")
  expect_error(
    register_geom("bad_oa2", optional_args = oa_empty_key),
    "fully named"
  )
})

test_that("register_geom: rejects optional_args entry missing 'default'", {
  expect_error(
    register_geom("bad_oa3",
      optional_args = list(x = list(desc = "no default field"))),
    "list\\(default"
  )
})

test_that("register_geom: rejects optional_args entry missing 'desc'", {
  expect_error(
    register_geom("bad_oa4",
      optional_args = list(x = list(default = 1))),
    "list\\(default"
  )
})

test_that("register_geom: rejects optional_args entry that is not a list", {
  expect_error(
    register_geom("bad_oa5",
      optional_args = list(x = "not a list")),
    "list\\(default"
  )
})

test_that("register_geom: error message names the bad entries", {
  expect_error(
    register_geom("bad_oa6",
      optional_args = list(
        good = .opt(1, "fine"),
        bad1 = list(default = 1),
        bad2 = "wrong type"
      )),
    "bad1"
  )
})

test_that("register_geom: empty optional_args is accepted", {
  on.exit(rm("empty_oa_geom", envir = highdir:::.geom_registry), add = TRUE)
  expect_silent(register_geom("empty_oa_geom", optional_args = list()))
})

test_that("register_geom: NULL default in optional_args is accepted", {
  on.exit(rm("null_default_geom", envir = highdir:::.geom_registry), add = TRUE)
  expect_silent(
    register_geom("null_default_geom",
      optional_args = list(x = list(default = NULL, desc = "nullable")))
  )
})


# =============================================================================
# 4.  Built-in geom contracts
# =============================================================================

test_that("arearange: required_args is named list with ymin and ymax", {
  g  <- highdir:::.get_geom("arearange")
  ra <- g$required_args
  expect_type(ra, "list")
  expect_true(all(c("ymin", "ymax") %in% names(ra)))
  expect_null(ra$ymin$default)
  expect_null(ra$ymax$default)
  expect_type(ra$ymin$desc, "character")
  expect_type(ra$ymax$desc, "character")
})

test_that("arearange: skip_base_fig is FALSE", {
  expect_false(isTRUE(highdir:::.get_geom("arearange")$skip_base_fig))
})

test_that("column: has no required_args and no optional_args", {
  g <- highdir:::.get_geom("column")
  expect_length(g$required_args, 0L)
  expect_length(g$optional_args, 0L)
})

test_that("pie: has no required_args", {
  expect_length(highdir:::.get_geom("pie")$required_args, 0L)
})

test_that("pie: has inner_size optional_arg with default '0%'", {
  oa <- highdir:::.get_geom("pie")$optional_args
  expect_true("inner_size" %in% names(oa))
  expect_equal(oa$inner_size$default, "0%")
})

test_that("line: optional_args contains smooth, dot_size, line_symbols", {
  oa <- highdir:::.get_geom("line")$optional_args
  expect_true(all(c("smooth", "dot_size", "line_symbols") %in% names(oa)))
  expect_true(isTRUE(oa$smooth$default))
  expect_equal(oa$dot_size$default, 4L)
  expect_null(oa$line_symbols$default)
})

# test_that("map: is_map_geom is TRUE", {
#   expect_true(isTRUE(highdir:::.get_geom("map")$is_map_geom))
# })

# test_that("map: optional_args contains level, low_col, high_col, na_fill", {
#   oa <- highdir:::.get_geom("map")$optional_args
#   expect_true(all(c("level", "low_col", "high_col", "na_fill") %in% names(oa)))
#   expect_equal(oa$level$default, "county")
# })

test_that("ranked_bar: optional_args contains ascending, vs, aim", {
  oa <- highdir:::.get_geom("ranked_bar")$optional_args
  expect_true(all(c("ascending", "vs", "aim") %in% names(oa)))
  expect_true(isTRUE(oa$ascending$default))
  expect_null(oa$comp$default)
})


# =============================================================================
# 5.  validate_geom_args() -- uses names(required_args)
# =============================================================================

test_that("validate_geom_args: passes when all required args are present", {
  geom <- list(
    name          = "test",
    required_args = list(ymin = .req(), ymax = .req())
  )
  expect_invisible(
    highdir:::validate_geom_args(geom, list(ymin = "lo", ymax = "hi"))
  )
})

test_that("validate_geom_args: passes when required_args is empty", {
  geom <- list(name = "test", required_args = list())
  expect_invisible(
    highdir:::validate_geom_args(geom, list())
  )
})

test_that("validate_geom_args: stops with 'Missing required' when args absent", {
  geom <- list(
    name          = "test",
    required_args = list(ymin = .req(), ymax = .req())
  )
  expect_error(
    highdir:::validate_geom_args(geom, list()),
    "Missing required"
  )
})

test_that("validate_geom_args: error names the missing arg", {
  geom <- list(
    name          = "test",
    required_args = list(ymin = .req(), ymax = .req())
  )
  expect_error(
    highdir:::validate_geom_args(geom, list(ymin = "lo")),
    "ymax"
  )
})

test_that("validate_geom_args: error mentions geom name", {
  geom <- list(
    name          = "arearange",
    required_args = list(ymin = .req(), ymax = .req())
  )
  expect_error(
    highdir:::validate_geom_args(geom, list()),
    "arearange"
  )
})

test_that("validate_geom_args: error suggests geom_args()", {
  geom <- list(
    name          = "arearange",
    required_args = list(ymin = .req())
  )
  expect_error(
    highdir:::validate_geom_args(geom, list()),
    "geom_args"
  )
})

test_that("validate_geom_args: extra args beyond required do not cause errors", {
  geom <- list(
    name          = "test",
    required_args = list(ymin = .req())
  )
  expect_invisible(
    highdir:::validate_geom_args(geom, list(ymin = "lo", smooth = TRUE))
  )
})


# =============================================================================
# 6.  geom_args() -- discoverability helper
# =============================================================================

test_that("geom_args: errors on unknown geometry", {
  expect_error(highdir:::geom_args("nonexistent_xyz"), "Unknown geometry")
})

test_that("geom_args: returns invisible data.frame", {
  result <- withVisible(highdir:::geom_args("line"))
  expect_false(result$visible)
  expect_s3_class(result$value, "data.frame")
})

test_that("geom_args: data.frame has columns argument, kind, default, desc", {
  df <- highdir:::geom_args("line")
  expect_true(all(c("argument", "kind", "default", "desc") %in% names(df)))
})

test_that("geom_args: required args have kind = 'required'", {
  df       <- highdir:::geom_args("arearange")
  req_rows <- df[df$kind == "required", ]
  expect_true(nrow(req_rows) >= 2L)
  expect_true(all(c("ymin", "ymax") %in% req_rows$argument))
})

test_that("geom_args: optional args have kind = 'optional'", {
  df       <- highdir:::geom_args("line")
  opt_rows <- df[df$kind == "optional", ]
  expect_true(nrow(opt_rows) >= 1L)
  expect_true(all(c("smooth", "dot_size") %in% opt_rows$argument))
})

test_that("geom_args: NULL default shown as string 'NULL'", {
  df       <- highdir:::geom_args("arearange")
  req_rows <- df[df$kind == "required", ]
  expect_true(all(req_rows$default == "NULL"))
})

test_that("geom_args: non-NULL default shown as character", {
  df         <- highdir:::geom_args("line")
  smooth_row <- df[df$argument == "smooth", ]
  expect_equal(smooth_row$default, "TRUE")
})

test_that("geom_args: geom with no args emits message and returns empty df", {
  expect_message(
    result <- highdir:::geom_args("column"),
    "no extra arguments"
  )
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 0L)
})

test_that("geom_args: NULL type iterates all geoms and returns NULL invisibly", {
  result <- withVisible(highdir:::geom_args(NULL))
  expect_false(result$visible)
  expect_null(result$value)
})

test_that("geom_args: printed output contains geometry name in header", {
  output <- capture.output(highdir:::geom_args("line"))
  expect_true(any(grepl("line", output)))
})

test_that("geom_args: printed output contains column headers", {
  output <- capture.output(highdir:::geom_args("line"))
  expect_true(any(grepl("argument", output, ignore.case = TRUE)))
  expect_true(any(grepl("kind",     output, ignore.case = TRUE)))
})

test_that("geom_args: works for a custom registered geom", {
  on.exit(rm("custom_geom_test", envir = highdir:::.geom_registry), add = TRUE)
  register_geom("custom_geom_test",
    required_args = list(
      mycol = list(default = NULL, desc = "Required column name")
    ),
    optional_args = list(
      myarg = list(default = 5L, desc = "An optional integer")
    )
  )

  df <- highdir:::geom_args("custom_geom_test")
  expect_true("mycol" %in% df$argument)
  expect_true("myarg" %in% df$argument)
  expect_equal(df[df$argument == "mycol", "kind"],    "required")
  expect_equal(df[df$argument == "myarg", "kind"],    "optional")
  expect_equal(df[df$argument == "myarg", "default"], "5")
})

##### Old test -----------------------------------------------------------------

test_that("built-in geoms registered at load", {
  g <- list_geoms()
  expect_true(all(c("column", "line", "scatter", "arearange", "pie") %in% g))
})

test_that("built-in backends registered at load", {
  b <- list_backends()
  expect_true(all(c("static", "dynamic") %in% b))
})

test_that("register_backend / get_backend round-trip", {
  eng <- function(spec, geom, opts, geom_params, use_js, filename, ...) NULL
  register_backend("test_backend", eng)
  expect_true("test_backend" %in% list_backends())
  expect_identical(get_backend("test_backend"), eng)
})

test_that("register_backend: rejects non-function", {
  expect_error(register_backend("bad", "oops"), "function")
})

test_that("register_geom / .get_geom round-trip", {
  register_geom("test_geom",
    ggplot_fun      = function(spec, opts, gp, ...) list(),
    highcharter_fun = function(chart, spec, opts, gp, ...) chart,
    required_args   = c("foo")
  )
  expect_true("test_geom" %in% list_geoms())
  g <- .get_geom("test_geom")
  expect_equal(g$required_args, "foo")
  expect_true(is.function(g$ggplot_fun))
})

test_that("validate_geom_args: passes when all required present", {
  g <- list(required_args = c("ymin", "ymax"))
  expect_invisible(validate_geom_args(g, list(ymin = "a", ymax = "b")))
})

test_that("validate_geom_args: stops on missing required args", {
  g <- list(required_args = list(ymin = NULL, ymax = NULL))
  expect_error(validate_geom_args(g, list()), "Missing required")
  expect_error(validate_geom_args(g, list(ymin = "a")), "ymax")
})

test_that("arearange has correct required_args", {
  g <- .get_geom("arearange")
  expect_setequal(names(g$required_args), c("ymin", "ymax"))
})

test_that("pie has no required_args", {
  expect_length(.get_geom("pie")$required_args, 0)
})
