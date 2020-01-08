


## Test environments

###  OSX (local machine using --as-cran from the command line)

    R CMD check --as-cran rqdatatable_1.2.5.tar.gz
    * using R version 3.6.0 (2019-04-26)
    * using platform: x86_64-apple-darwin15.6.0 (64-bit)
    * using session charset: UTF-8
    * using option ‘--as-cran’
    * checking for file ‘rqdatatable/DESCRIPTION’ ... OK
    * checking extension type ... Package
    * this is package ‘rqdatatable’ version ‘1.2.5’
    * package encoding: UTF-8
    * checking CRAN incoming feasibility ... Note_to_CRAN_maintainers
    Maintainer: ‘John Mount <jmount@win-vector.com>’
    Status: OK

### Windows

     rhub::check_for_cran()
     492#> setting _R_CHECK_FORCE_SUGGESTS_ to false
     493#> setting R_COMPILE_AND_INSTALL_PACKAGES to never
     494#> setting R_REMOTES_STANDALONE to true
     495#> setting R_REMOTES_NO_ERRORS_FROM_WARNINGS to true
     496#> setting _R_CHECK_FORCE_SUGGESTS_ to true
     497#> setting _R_CHECK_CRAN_INCOMING_USE_ASPELL_ to true
     498#> * using log directory 'C:/Users/USERQeSVTgWuoh/rqdatatable.Rcheck'
     499#> * using R Under development (unstable) (2019-11-08 r77393)
     500#> * using platform: x86_64-w64-mingw32 (64-bit)
     501#> * using session charset: ISO8859-1
     502#> * using option '--as-cran'
     503#> * checking for file 'rqdatatable/DESCRIPTION' ... OK
     504#> * checking extension type ... Package
     505#> * this is package 'rqdatatable' version '1.2.5'
     506#> * package encoding: UTF-8
     507#> * checking CRAN incoming feasibility ... Note_to_CRAN_maintainers
     508#> Maintainer: 'John Mount '
     564#> Status: OK

 
## Reverse dependencies

    Checked reverse dependencies ( https://github.com/WinVector/rqdatatable/blob/master/extras/check_reverse_dependencies.md ).


Note: Codd is spelled correctly.

