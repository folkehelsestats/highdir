# Example dataset general with group

General dataset with 95% CI with grouping.

## Usage

``` r
dtalko2
```

## Format

A data data.table format

## Source

Imported from an external file

## Examples

``` r
data("dtalko2")
head(dtalko2)
#>     kjonn  year adj_mean       SE lower_95CI upper_95CI adj_enhet SE_enhet
#>    <char> <int>    <num>    <num>      <num>      <num>     <num>    <num>
#> 1:      1  2012 39.95345 2.379615   35.28376   44.62313      26.6      1.6
#> 2:      1  2013 36.43661 1.588756   33.31914   39.55408      24.3      1.1
#> 3:      1  2014 40.12185 2.054620   36.09022   44.15348      26.7      1.4
#> 4:      1  2015 33.50714 1.632232   30.30450   36.70977      22.3      1.1
#> 5:      1  2016 33.80000 1.932028   30.00890   37.59110      22.5      1.3
#> 6:      1  2017 34.04078 1.492390   31.11246   36.96909      22.7      1.0
#>    lower_enhet upper_enhet
#>          <num>       <num>
#> 1:        23.5        29.7
#> 2:        22.2        26.4
#> 3:        24.1        29.4
#> 4:        20.2        24.5
#> 5:        20.0        25.1
#> 6:        20.7        24.6
```
