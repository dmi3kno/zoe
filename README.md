
<!-- README.md is generated from README.Rmd. Please edit that file -->

# zoe

The goal of `zoe` is to provide data about new and used car registratons
and in particular about the rise of zero-emission vehicles in Norway.
Norway went from diesel-dominated car fleet to primarily hybrid and
zero-emission cars in the course of last decade. Understanding of market
dynamics, influence of competition, government policy and consumer
preferences could be facilitated through data analysis of the datasets
included in this package.

## Installation

You can install the development version of `zoe` from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("dmi3kno/zoe")
```

## Example

In this version of the package two datasets are included. `bilsalget`
(“car sales” in Norwegian) contains information about monthly new
vehicle registrations.

``` r
library(zoe)
bilsalget_raw
#> # A tibble: 69,634 x 8
#>    car_name           year month series       source metric period value
#>    <chr>             <dbl> <int> <chr>        <chr>  <chr>  <chr>  <dbl>
#>  1 TOTAL              2017     1 total models top    CM     CY     13055
#>  2 Volkswagen Golf    2017     1 models       top    CM     CY       738
#>  3 BMW i3             2017     1 models       top    CM     CY       622
#>  4 Volkswagen Passat  2017     1 models       top    CM     CY       515
#>  5 Toyota Rav4        2017     1 models       top    CM     CY       473
#>  6 Volvo XC90         2017     1 models       top    CM     CY       411
#>  7 Skoda Octavia      2017     1 models       top    CM     CY       358
#>  8 Nissan Leaf        2017     1 models       top    CM     CY       352
#>  9 Toyota Yaris       2017     1 models       top    CM     CY       343
#> 10 Mercedes-Benz GLC  2017     1 models       top    CM     CY       285
#> # ... with 69,624 more rows
```

Raw version of the dataset is provided in the “long” format. The dataset
contains 3 time series (models, makes and monthly totals) from different
sources (tables and images published on www.ofvas.no)

Zero-emission vehicles are described in `zoe` dataset. This data
contains monthly totals of new car registrations, used car import, share
of diesel vehicles, average co2 emission of new vehicles, number of
hybrids and zero-emission vehicles registred in the country.

``` r
library(zoe)
zoe_raw
#> # A tibble: 162 x 14
#>     year month total import_used turnover_used avg_co2 bensin_co2
#>    <int> <int> <dbl>       <dbl>         <dbl>   <dbl>      <dbl>
#>  1  2005     1  7375        1768            NA      NA         NA
#>  2  2005     2  8325        1934            NA      NA         NA
#>  3  2005     3  9493        2043            NA      NA         NA
#>  4  2005     4 10089        2377            NA      NA         NA
#>  5  2005     5  9714        2429            NA      NA         NA
#>  6  2005     6  9879        2517            NA      NA         NA
#>  7  2005     7  9690        3651            NA      NA         NA
#>  8  2005     8  8544        3019            NA      NA         NA
#>  9  2005     9  8795        2893            NA      NA         NA
#> 10  2005    10  8884        2642            NA      NA         NA
#> # ... with 152 more rows, and 7 more variables: diesel_co2 <dbl>,
#> #   diesel_share <dbl>, total_hybrid <dbl>, total_zoe <dbl>,
#> #   import_used_zoe <dbl>, href <chr>, comment <chr>
```

Raw version of the dataset is provided in the “wide” format. The dataset
contains several time series recorded primarily from analysis
commentaries on www.ofvas.no website. Original text of commentaries is
also provided (in Norwegian).
