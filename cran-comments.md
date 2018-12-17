
## Test environments

###  OSX (local machine using --as-cran from the command line)

    R CMD check --as-cran rqdatatable_1.1.2.tar.gz
    * using R version 3.5.0 (2018-04-23)
    * using platform: x86_64-apple-darwin15.6.0 (64-bit)
    * using session charset: UTF-8
    * using option ‘--as-cran’
    * checking for file ‘rqdatatable/DESCRIPTION’ ... OK
    * checking extension type ... Package
    * this is package ‘rqdatatable’ version ‘1.1.2’
    * package encoding: UTF-8
    * checking CRAN incoming feasibility ... Note_to_CRAN_maintainers
    Maintainer: ‘John Mount <jmount@win-vector.com>’
    Status: OK

###  Linux (local machine using --as-cran from the command line)

    R CMD check --as-cran rqdatatable_1.1.2.tar.gz
    * using R version 3.5.1 (2018-07-02)
    * using platform: x86_64-pc-linux-gnu (64-bit)
    * using session charset: UTF-8
    * using option ‘--as-cran’
    * checking for file ‘rqdatatable/DESCRIPTION’ ... OK
    * checking extension type ... Package
    * this is package ‘rqdatatable’ version ‘1.1.2’
    * package encoding: UTF-8
    * checking CRAN incoming feasibility ... Note_to_CRAN_maintainers
    Maintainer: ‘John Mount <jmount@win-vector.com>’
    Status: OK

### Windows 

    devtools::build_win()
    * using R Under development (unstable) (2018-12-17 r75857)
    * using platform: x86_64-w64-mingw32 (64-bit)
    * using session charset: ISO8859-1
    * checking for file 'rqdatatable/DESCRIPTION' ... OK
    * checking extension type ... Package
    * this is package 'rqdatatable' version '1.1.2'
    * package encoding: UTF-8
    * checking CRAN incoming feasibility ... Note_to_CRAN_maintainers
    Maintainer: 'John Mount <jmount@win-vector.com>'
    Status: OK

    rhub::check_for_cran()
    574#> * using log directory 'C:/Users/USERkxBqLbrWTc/rqdatatable.Rcheck'
    575#> * using R Under development (unstable) (2018-11-18 r75627)
    576#> * using platform: x86_64-w64-mingw32 (64-bit)
    577#> * using session charset: ISO8859-1
    578#> * using option '--as-cran'
    579#> * checking for file 'rqdatatable/DESCRIPTION' ... OK
    580#> * checking extension type ... Package
    581#> * this is package 'rqdatatable' version '1.1.2'
    582#> * package encoding: UTF-8
    583#> * checking CRAN incoming feasibility ... Note_to_CRAN_maintainers
    584#> Maintainer: 'John Mount '
    638#> Status: OK

## Reverse dependencies

    All reverse dependencies check okay.
    devtools::revdep_check()
    Checking 3 packages: cdata, rquery, vtreat
    Checked cdata : 0 errors | 0 warnings | 0 notes
    Checked rquery: 0 errors | 0 warnings | 0 notes
    Checked vtreat: 0 errors | 0 warnings | 0 notes

Note: Codd is spelled correctly.

