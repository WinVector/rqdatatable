


## Test environments

###  OSX (local machine using --as-cran from the command line)

    R CMD check --as-cran rqdatatable_1.2.2.tar.gz
    * using R version 3.6.0 (2019-04-26)
    * using platform: x86_64-apple-darwin15.6.0 (64-bit)
    * using session charset: UTF-8
    * using option ‘--as-cran’
    * checking for file ‘rqdatatable/DESCRIPTION’ ... OK
    * checking extension type ... Package
    * this is package ‘rqdatatable’ version ‘1.2.2’
    * package encoding: UTF-8
    * checking CRAN incoming feasibility ... Note_to_CRAN_maintainers
    Maintainer: ‘John Mount <jmount@win-vector.com>’
    Status: OK


### Windows 

    rhub::check_for_cran()
    509#> * using R Under development (unstable) (2019-08-30 r77101)
    510#> * using platform: x86_64-w64-mingw32 (64-bit)
    511#> * using session charset: ISO8859-1
    512#> * using option '--as-cran'
    513#> * checking for file 'rqdatatable/DESCRIPTION' ... OK
    514#> * checking extension type ... Package
    515#> * this is package 'rqdatatable' version '1.2.2'
    516#> * package encoding: UTF-8
    517#> * checking CRAN incoming feasibility ... Note_to_CRAN_maintainers
    518#> Maintainer: 'John Mount '
    574#> Status: OK
 
## Reverse dependencies

    Checked reverse dependencies ( https://github.com/WinVector/rqdatatable/blob/master/extras/check_reverse_dependencies.md ).


Note: Codd is spelled correctly.

