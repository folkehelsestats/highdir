# R/palettes.R ── Named colour palette registry
#
# Palettes are stored in a plain environment (.palette_registry).  Built-in
# palettes are registered in .onLoad() (see zzz.R).  Users and extension
# packages can add their own with register_palette().
#
# resolve_colors() is the *single* function every geom calls to obtain a
# colour vector — it respects both explicit overrides and session defaults.

# -- Registry environment ------------------------------------------------------

#' @keywords internal
.palette_registry <- new.env(parent = emptyenv())

# -- Public API ----------------------------------------------------------------

#' Register a Named Colour Palette
#'
#' Adds a named palette to the highdir palette registry so it can be
#' referenced by name wherever colours are accepted
#' (e.g. `hd_opts(colors = "my_palette")`). This function is evaluated
#' when loading a file in zzz.R file.
#'
#' Built-in palettes registered at package load time:
#'
#' | Name     | Description                               |
#' |:---------|:------------------------------------------|
#' | `"hdir"` | Helsedirektoratet 10-colour brand palette |
#' | `"hdir2"`| 2-colour teal / purple pair               |
#'
#' @param name   Character. Unique palette identifier.
#' @param colors Non-empty character vector of CSS/hex colour strings.
#'
#' @return `name`, invisibly.
#'
#' @examples
#' register_palette("blues", c("#084594", "#2171b5", "#4292c6", "#6baed6"))
#' get_palette("blues")
#'
#' @export
register_palette <- function(name, colors) {
  if (!is.character(colors) || length(colors) == 0)
    stop("`colors` must be a non-empty character vector.", call. = FALSE)
  .palette_registry[[name]] <- colors
  invisible(name)
}

#' List Registered Palettes
#'
#' @return Character vector of registered palette names.
#' @examples
#' list_palettes()
#' @export
list_palettes <- function() sort(ls(.palette_registry))

#' Retrieve a Named Palette
#'
#' @param name Character. Palette name (see [list_palettes()]).
#' @return Character vector of colours, or `NULL` if not found.
#' @examples
#' get_palette("hdir")
#' @export
get_palette <- function(name) .palette_registry[[name]]

# -- Colour resolution (internal) ----------------------------------------------
# R/palettes.R

#' Resolve a Colour Vector for n Groups
#'
#' Returns exactly `n` colours. Priority order:
#'
#' 1. Explicit `colors` argument — vector or palette name string.
#' 2. `getOption("highdir.colors")` — set via [hd_set_theme()].
#' 3. Built-in hdir rules:
#'    * n == 2  → `"hdir2"` two-colour teal/purple pair
#'    * n <= 10 → `"hdir"` 10-colour brand palette
#'    * n > 10  → viridis continuous scale
#'
#' @param n      Integer. Number of colours required.
#' @param colors Character vector, palette name, or `NULL`.
#' @return Character vector of exactly length `n`.
#' @keywords internal
resolve_colors <- function(n, colors = NULL) {

  # -- Priority 1 + 2: explicit or session-level override ----------------------
  candidate <- colors %||% getOption("highdir.colors", default = NULL)

  if (!is.null(candidate)) {
    # Resolve palette name string → colour vector
    if (is.character(candidate) && length(candidate) == 1 &&
        candidate %in% list_palettes()) {
      candidate <- get_palette(candidate)
    }
    if (length(candidate) >= n)
      return(candidate[seq_len(n)])

    warning(
      "Supplied palette has ", length(candidate), " colour(s) but ",
      n, " are needed. Falling back to built-in rules.",
      call. = FALSE
    )
  }

  # -- Priority 3: built-in n-aware rules --------------------------------------

  # Rule A — exactly 2 groups: dedicated high-contrast pair
  if (n == 2) {
    pal2 <- get_palette("hdir2")
    if (!is.null(pal2) && length(pal2) >= 2)
      return(pal2[seq_len(n)])
  }

  # Rule B — up to 10 groups: first n from hdir
  hdir_pal <- get_palette("hdir")
  if (!is.null(hdir_pal) && n <= length(hdir_pal))
    return(hdir_pal[seq_len(n)])

  # Rule C — more than 10 groups: viridis continuous interpolation
  if (!requireNamespace("viridis", quietly = TRUE))
    stop(
      n, " colours requested but hdir only has 10 and {viridis} is not ",
      "installed.\nInstall it: install.packages('viridis')",
      call. = FALSE
    )
  viridis::viridis(n, option = "D")
}
