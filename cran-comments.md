


## Test environments

###  OSX (local machine using --as-cran from the command line)

    R CMD check --as-cran rqdatatable_1.2.4.tar.gz
    * using R version 3.6.0 (2019-04-26)
    * using platform: x86_64-apple-darwin15.6.0 (64-bit)
    * using session charset: UTF-8
    * using option ‘--as-cran’
    * checking for file ‘rqdatatable/DESCRIPTION’ ... OK
    * checking extension type ... Package
    * this is package ‘rqdatatable’ version ‘1.2.4’
    * package encoding: UTF-8
    * checking CRAN incoming feasibility ... Note_to_CRAN_maintainers
    Maintainer: ‘John Mount <jmount@win-vector.com>’
    Status: OK


### Linux

    rhub::check_for_cran()
     498#> * using R Under development (unstable) (2019-11-08 r77393)
     499#> * using platform: x86_64-w64-mingw32 (64-bit)
     500#> * using session charset: ISO8859-1
     501#> * using option '--as-cran'
     502#> * checking for file 'rqdatatable/DESCRIPTION' ... OK
     503#> * checking extension type ... Package
     504#> * this is package 'rqdatatable' version '1.2.4'
     505#> * package encoding: UTF-8
     506#> * checking CRAN incoming feasibility ... Note_to_CRAN_maintainers
     507#> Maintainer: 'John Mount '
     563#> Status: OK
 
## Reverse dependencies

    Checked reverse dependencies ( https://github.com/WinVector/rqdatatable/blob/master/extras/check_reverse_dependencies.md ).


Note: Codd is spelled correctly.

