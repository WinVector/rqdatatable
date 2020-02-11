
## Test environments

###  OSX (local machine using --as-cran from the command line)

    R CMD check --as-cran rqdatatable_1.2.7.tar.gz
    * using R version 3.6.2 (2019-12-12)
    * using platform: x86_64-apple-darwin15.6.0 (64-bit)
    * using session charset: UTF-8
    * using option ‘--as-cran’
    * checking for file ‘rqdatatable/DESCRIPTION’ ... OK
    * checking extension type ... Package
    * this is package ‘rqdatatable’ version ‘1.2.7’
    * package encoding: UTF-8
    * checking CRAN incoming feasibility ... Note_to_CRAN_maintainers
    Maintainer: ‘John Mount <jmount@win-vector.com>’
    Status: OK

### Windows

     rhub::check_for_cran()
     606#> setting _R_CHECK_FORCE_SUGGESTS_ to false
     607#> setting R_COMPILE_AND_INSTALL_PACKAGES to never
     608#> setting R_REMOTES_STANDALONE to true
     609#> setting R_REMOTES_NO_ERRORS_FROM_WARNINGS to true
     610#> setting _R_CHECK_FORCE_SUGGESTS_ to true
     611#> setting _R_CHECK_CRAN_INCOMING_USE_ASPELL_ to true
     612#> * using log directory 'C:/Users/USERFwQKDcYMNn/rqdatatable.Rcheck'
     613#> * using R Under development (unstable) (2020-01-22 r77697)
     614#> * using platform: x86_64-w64-mingw32 (64-bit)
     615#> * using session charset: ISO8859-1
     616#> * using option '--as-cran'
     617#> * checking for file 'rqdatatable/DESCRIPTION' ... OK
     618#> * checking extension type ... Package
     619#> * this is package 'rqdatatable' version '1.2.7'
     620#> * package encoding: UTF-8
     621#> * checking CRAN incoming feasibility ... Note_to_CRAN_maintainers
     622#> Maintainer: 'John Mount '
     678#> Status: OK
 
## Reverse dependencies

    Checked reverse dependencies ( https://github.com/WinVector/rqdatatable/blob/master/extras/check_reverse_dependencies.md ).

Note: Codd is spelled correctly.
