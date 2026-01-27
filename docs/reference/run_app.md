# Run the highdir Shiny app

Launches the interactive app for creating charts with highdir functions.
Use parameters to change defaults or pass feature flags.

## Usage

``` r
run_app(
  ...,
  .return_app = FALSE,
  host = getOption("shiny.host", "127.0.0.1"),
  port = getOption("shiny.port"),
  launch.browser = getOption("shiny.launch.browser", interactive())
)
```

## Arguments

- ...:

  Named options passed to the app (optional).

- .return_app:

  logical. If `TRUE`, return the `shiny.appobj` instead of launching it.
  Default is `FALSE`.

- host:

  Host to listen on (default "127.0.0.1").

- port:

  Port to listen on (default: random).

- launch.browser:

  Open browser automatically? (default: interactive())

## Value

A `shiny.appobj`; called for its side effects.

## Examples

``` r
if (FALSE)  highdir::run_app()  # \dontrun{}
```
