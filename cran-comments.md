


## Test environments

###  OSX (local machine using --as-cran from the command line)

    R CMD check --as-cran rqdatatable_1.2.0.tar.gz
    * using R version 3.6.0 (2019-04-26)
    * using platform: x86_64-apple-darwin15.6.0 (64-bit)
    * using session charset: UTF-8
    * using option ‘--as-cran’
    * checking for file ‘rqdatatable/DESCRIPTION’ ... OK
    * checking extension type ... Package
    * this is package ‘rqdatatable’ version ‘1.2.0’
    * package encoding: UTF-8
    * checking CRAN incoming feasibility ... Note_to_CRAN_maintainers
    Maintainer: ‘John Mount <jmount@win-vector.com>’
    Status: OK

### Windows 

    rhub::check_for_cran()
     502#> setting _R_CHECK_FORCE_SUGGESTS_ to false
    503#> setting R_COMPILE_AND_INSTALL_PACKAGES to never
    504#> setting R_REMOTES_STANDALONE to true
    505#> setting R_REMOTES_NO_ERRORS_FROM_WARNINGS to true
    506#> setting _R_CHECK_FORCE_SUGGESTS_ to true
    507#> setting _R_CHECK_CRAN_INCOMING_USE_ASPELL_ to true
    508#> * using log directory 'C:/Users/USERjWadoxgtyS/rqdatatable.Rcheck'
    509#> * using R Under development (unstable) (2019-07-04 r76780)
    510#> * using platform: x86_64-w64-mingw32 (64-bit)
    511#> * using session charset: ISO8859-1
    512#> * using option '--as-cran'
    513#> * checking for file 'rqdatatable/DESCRIPTION' ... OK
    514#> * checking extension type ... Package
    515#> * this is package 'rqdatatable' version '1.2.0'
    516#> * package encoding: UTF-8
    517#> * checking CRAN incoming feasibility ... Note_to_CRAN_maintainers
    518#> Maintainer: 'John Mount '
    572#> * DONE
    573#> Status: OK
 
## Reverse dependencies

    Checked reverse dependencies ( https://github.com/WinVector/rqdatatable/blob/master/extras/check_reverse_dependencies.md ).
    ## cdata_1.1.1 started at 2019-08-19 06:54:20 success at 2019-08-19 06:54:55 (1/0/0)
    ## Test of rqdatatable had 1 successes, 0 failures, and 0 skipped packages. 

Note: Codd is spelled correctly.

