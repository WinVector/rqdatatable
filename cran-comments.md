
## Test environments

###  OSX (local machine using --as-cran from the command line)

    R CMD check --as-cran rqdatatable_1.2.5.tar.gz
    * using R version 3.6.0 (2019-04-26)
    * using platform: x86_64-apple-darwin15.6.0 (64-bit)
    * using session charset: UTF-8
    * using option ‘--as-cran’
    * checking for file ‘rqdatatable/DESCRIPTION’ ... OK
    * checking extension type ... Package
    * this is package ‘rqdatatable’ version ‘1.2.6’
    * package encoding: UTF-8
    * checking CRAN incoming feasibility ... Note_to_CRAN_maintainers
    Maintainer: ‘John Mount <jmount@win-vector.com>’
    Status: OK 

### Windows

     rhub::check_for_cran()
     631#> setting _R_CHECK_FORCE_SUGGESTS_ to false
     632#> setting R_COMPILE_AND_INSTALL_PACKAGES to never
     633#> setting R_REMOTES_STANDALONE to true
     634#> setting R_REMOTES_NO_ERRORS_FROM_WARNINGS to true
     635#> setting _R_CHECK_FORCE_SUGGESTS_ to true
     636#> setting _R_CHECK_CRAN_INCOMING_USE_ASPELL_ to true
     637#> * using log directory 'C:/Users/USERIEjBPzVFLX/rqdatatable.Rcheck'
     638#> * using R Under development (unstable) (2020-01-22 r77697)
     639#> * using platform: x86_64-w64-mingw32 (64-bit)
     640#> * using session charset: ISO8859-1
     641#> * using option '--as-cran'
     642#> * checking for file 'rqdatatable/DESCRIPTION' ... OK
     643#> * checking extension type ... Package
     644#> * this is package 'rqdatatable' version '1.2.6'
     645#> * package encoding: UTF-8
     646#> * checking CRAN incoming feasibility ... Note_to_CRAN_maintainers
     647#> Maintainer: 'John Mount '
     703#> Status: OK
 
## Reverse dependencies

    Checked reverse dependencies ( https://github.com/WinVector/rqdatatable/blob/master/extras/check_reverse_dependencies.md ).

Note: Codd is spelled correctly.
