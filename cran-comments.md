
## Test environments

###  OSX (local machine using --as-cran from the command line)

    R CMD check --as-cran rqdatatable_1.2.8.tar.gz
    * using R version 4.0.2 (2020-06-22)
    * using platform: x86_64-apple-darwin17.0 (64-bit)
    * using session charset: UTF-8
    * using option ‘--as-cran’
    * checking for file ‘rqdatatable/DESCRIPTION’ ... OK
    * checking extension type ... Package
    * this is package ‘rqdatatable’ version ‘1.2.8’
    * package encoding: UTF-8
    * checking CRAN incoming feasibility ... Note_to_CRAN_maintainers
    Maintainer: ‘John Mount <jmount@win-vector.com>’
    ...
    Status: OK

### Windows

    rhub::check_for_cran()
    616#> setting _R_CHECK_FORCE_SUGGESTS_ to false
    617#> setting R_COMPILE_AND_INSTALL_PACKAGES to never
    618#> setting _R_CHECK_THINGS_IN_CHECK_DIR_ to false
    619#> setting R_REMOTES_STANDALONE to true
    620#> setting R_REMOTES_NO_ERRORS_FROM_WARNINGS to true
    621#> setting _R_CHECK_FORCE_SUGGESTS_ to true
    622#> setting _R_CHECK_CRAN_INCOMING_USE_ASPELL_ to true
    623#> * using log directory 'C:/Users/USERDvkCneyPfA/rqdatatable.Rcheck'
    624#> * using R Under development (unstable) (2020-07-05 r78784)
    625#> * using platform: x86_64-w64-mingw32 (64-bit)
    626#> * using session charset: ISO8859-1
    627#> * using option '--as-cran'
    628#> * checking for file 'rqdatatable/DESCRIPTION' ... OK
    629#> * checking extension type ... Package
    630#> * this is package 'rqdatatable' version '1.2.8'
    631#> * package encoding: UTF-8
    632#> * checking CRAN incoming feasibility ... Note_to_CRAN_maintainers
    633#> Maintainer: 'John Mount '
    689#> Status: OK
 

## Reverse dependencies

    Checked reverse dependencies ( https://github.com/WinVector/rqdatatable/blob/master/extras/check_reverse_dependencies.md ).

Note: Codd is spelled correctly.
