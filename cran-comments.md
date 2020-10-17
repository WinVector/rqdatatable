
## Test environments

###  OSX (local machine using --as-cran from the command line)

    R CMD check --as-cran rqdatatable_1.2.9.tar.gz 
    * using log directory ‘/Users/johnmount/Documents/work/rqdatatable.Rcheck’
    * using R version 4.0.2 (2020-06-22)
    * using platform: x86_64-apple-darwin17.0 (64-bit)
    * using session charset: UTF-8
    * using option ‘--as-cran’
    * checking for file ‘rqdatatable/DESCRIPTION’ ... OK
    * checking extension type ... Package
    * this is package ‘rqdatatable’ version ‘1.2.9’
    * package encoding: UTF-8
    * checking CRAN incoming feasibility ... Note_to_CRAN_maintainers
    Maintainer: ‘John Mount <jmount@win-vector.com>’
    ...
    Status: OK

### Windows

    rhub::check_for_cran()
    763#> setting _R_CHECK_FORCE_SUGGESTS_ to false
    764#> setting R_COMPILE_AND_INSTALL_PACKAGES to never
    765#> setting _R_CHECK_THINGS_IN_CHECK_DIR_ to false
    766#> setting R_REMOTES_STANDALONE to true
    767#> setting R_REMOTES_NO_ERRORS_FROM_WARNINGS to true
    768#> setting _R_CHECK_FORCE_SUGGESTS_ to true
    769#> setting _R_CHECK_CRAN_INCOMING_USE_ASPELL_ to true
    770#> * using log directory 'C:/Users/USEReconhqNYZb/rqdatatable.Rcheck'
    771#> * using R Under development (unstable) (2020-10-09 r79317)
    772#> * using platform: x86_64-w64-mingw32 (64-bit)
    773#> * using session charset: ISO8859-1
    774#> * using option '--as-cran'
    775#> * checking for file 'rqdatatable/DESCRIPTION' ... OK
    776#> * checking extension type ... Package
    777#> * this is package 'rqdatatable' version '1.2.9'
    778#> * package encoding: UTF-8
    779#> * checking CRAN incoming feasibility ... Note_to_CRAN_maintainers
    780#> Maintainer: 'John Mount '
    836#> Status: OK

 
    devtools::check_win_devel()
 

## Reverse dependencies

    Checked reverse dependencies ( https://github.com/WinVector/rqdatatable/blob/master/extras/check_reverse_dependencies.md ).

Note: Codd is spelled correctly.
