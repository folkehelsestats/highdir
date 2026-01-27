# Example dataset general

General dataset with 95% CI.

## Usage

``` r
dtalko1
```

## Format

A data data.table format

## Source

Imported from an external file

## Examples

``` r
data("dtalko1")
head(dtalko1)
#>     year adj_mean        SE lower_95CI upper_95CI adj_enhet SE_enhet
#>    <int>    <num>     <num>      <num>      <num>     <num>    <num>
#> 1:  2012 29.56882 1.3140182   26.99179   32.14585      19.7      0.9
#> 2:  2013 26.38208 0.8982238   24.62058   28.14358      17.6      0.6
#> 3:  2014 30.24792 1.2201785   27.85505   32.64079      20.2      0.8
#> 4:  2015 24.94079 0.9579391   23.06225   26.81934      16.6      0.6
#> 5:  2016 25.15521 1.0713897   23.05408   27.25633      16.8      0.7
#> 6:  2017 27.70677 0.9533279   25.83725   29.57629      18.5      0.6
#>    lower_enhet upper_enhet
#>          <num>       <num>
#> 1:        18.0        21.4
#> 2:        16.4        18.8
#> 3:        18.6        21.8
#> 4:        15.4        17.9
#> 5:        15.4        18.2
#> 6:        17.2        19.7
```
