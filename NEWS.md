# highdir 0.3.0

### New features

* Added **`"map"` geometry** — Norway choropleth maps at county (`level = "county"`)
  and municipality (`level = "municipality"`) resolution.
  - `gg_map`: static sf/ggplot2 choropleth.  Geometry downloaded from the
    Highcharts CDN on first use and cached in the session.  Requires **{sf}**.
  - `hc_map`: interactive Highcharter/Highmaps choropleth.  Uses
    `highcharter::hcmap()` with Highcharts-hosted TopoJSON loaded at render time.
  - New args in `hd_make()`: `level`, `value_lab`, `low_col`, `high_col`, `na_fill`.
  - Accepts SSB region codes as integers (`301`), zero-padded strings (`"0301"`),
    or full Highcharts hc-keys (`"no-03-0301"`).

* `no_counties()` — returns the 15 Norwegian counties (2024) with SSB
  `fylkesnummer`, names, and `hc_key` values.

* `no_municipalities()` — returns representative Norwegian municipalities with
  `kommunenummer`, names, `hc_key`, and `fylkesnummer`.

* `.norm_code()` and `.to_hc_key()` — internal helpers for converting SSB
  codes to Highcharts hc-key format.

* `.norway_sf_cache` — session-level environment caching downloaded sf geometry
  so maps after the first are instantaneous.

### Package changes

* `DESCRIPTION` version bumped to 0.3.0.
* `maps` added to `Suggests` (fallback for offline gg_map).
* Shiny app UI / server updated with map-specific controls (level, scale
  colours, NA fill, legend label).

# highdir 0.2.0

* Initial release with `column`, `line`, `scatter`, `arearange` geometries.
* `highcharter` and `ggplot2` backends.
* `hd_save()`, `hd_set_theme()`, `hd_add_js()`.
* Shiny GUI via `run_app()`.

# highdir 0.1.0

* Implement registry to control geoms
* Just a skeleton for highdir structure with very basic functions

# highdir 0.0.0.9000

* Birth of *highdir* using existing function.
* No planned structure
* For demo purpose only to show what *highdir* can offer and its potential.
