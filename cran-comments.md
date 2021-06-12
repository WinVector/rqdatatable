
## Test environments

###  OSX (local machine using --as-cran from the command line)

    R CMD check --as-cran rqdatatable_1.3.0.tar.gz
    R CMD check --as-cran rqdatatable_1.3.0.tar.gz 
    * using log directory ‘/Users/johnmount/Documents/work/rqdatatable.Rcheck’
    * using R version 4.0.2 (2020-06-22)
    * using platform: x86_64-apple-darwin17.0 (64-bit)
    * using session charset: UTF-8
    * using option ‘--as-cran’
    * checking for file ‘rqdatatable/DESCRIPTION’ ... OK
    * checking extension type ... Package
    * this is package ‘rqdatatable’ version ‘1.3.0’
    * package encoding: UTF-8
    * checking CRAN incoming feasibility ... Note_to_CRAN_maintainers
    ...
    Status: OK

### Windows

    


 
    devtools::check_win_devel()
    ...


### Linux

    rhub::check_for_cran()
    2212#> About to run xvfb-run R CMD check --as-cran rqdatatable_1.3.0.tar.gz
    2218#> * using R version 4.1.0 (2021-05-18)
    2219#> * using platform: x86_64-pc-linux-gnu (64-bit)
    2226#> * checking CRAN incoming feasibility ... Note_to_CRAN_maintainers
    2227#> Maintainer: ‘John Mount ’
    2284#> Status: OK

    rhub::check_for_cran()
    1878#> About to run xvfb-run R CMD check --as-cran rqdatatable_1.3.0.tar.gz
    1882#> * using R Under development (unstable) (2021-06-10 r80480)
    1883#> * using platform: x86_64-pc-linux-gnu (64-bit)
    1890#> * checking CRAN incoming feasibility ... Note_to_CRAN_maintainers
    1891#> Maintainer: ‘John Mount ’
    1948#> Status: OK

## Reverse dependencies

    Checked reverse dependencies ( https://github.com/WinVector/rqdatatable/blob/master/extras/check_reverse_dependencies.md ).

Note: Codd is spelled correctly.
