


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
     671#> setting _R_CHECK_FORCE_SUGGESTS_ to false
     672#> setting R_COMPILE_AND_INSTALL_PACKAGES to never
     673#> setting R_REMOTES_STANDALONE to true
     674#> setting R_REMOTES_NO_ERRORS_FROM_WARNINGS to true
     675#> setting _R_CHECK_FORCE_SUGGESTS_ to true
     676#> setting _R_CHECK_CRAN_INCOMING_USE_ASPELL_ to true
     677#> * using log directory 'C:/Users/USERLojYUCPwXH/rqdatatable.Rcheck'
     678#> * using R Under development (unstable) (2020-01-07 r77637)
     679#> * using platform: x86_64-w64-mingw32 (64-bit)
     680#> * using session charset: ISO8859-1
     681#> * using option '--as-cran'
     682#> * checking for file 'rqdatatable/DESCRIPTION' ... OK
     683#> * checking extension type ... Package
     684#> * this is package 'rqdatatable' version '1.2.5'
     685#> * package encoding: UTF-8
     686#> * checking CRAN incoming feasibility ... Note_to_CRAN_maintainers
     687#> Maintainer: 'John Mount '
     743#> Status: OK

 
## Reverse dependencies

    Checked reverse dependencies ( https://github.com/WinVector/rqdatatable/blob/master/extras/check_reverse_dependencies.md ).


Note: Codd is spelled correctly.

