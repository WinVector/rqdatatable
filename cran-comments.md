
## Test environments

###  OSX (local machine using --as-cran from the command line)

    R CMD check --as-cran rqdatatable_1.1.0.tar.gz
    * using R version 3.5.0 (2018-04-23)
    * using platform: x86_64-apple-darwin15.6.0 (64-bit)
    * using session charset: UTF-8
    * using option ‘--as-cran’
    * checking for file ‘rqdatatable/DESCRIPTION’ ... OK
    * checking extension type ... Package
    * this is package ‘rqdatatable’ version ‘1.1.0’
    * package encoding: UTF-8
    * checking CRAN incoming feasibility ... Note_to_CRAN_maintainers
    Maintainer: ‘John Mount <jmount@win-vector.com>’
    Status: OK


### Windows ( win-builder.r-project.org uses --as-cran )

    devtools::build_win()
    * using R Under development (unstable) (2018-09-18 r75325)
    * using platform: x86_64-w64-mingw32 (64-bit)
    * using session charset: ISO8859-1
    * checking for file 'rqdatatable/DESCRIPTION' ... OK
    * checking extension type ... Package
    * this is package 'rqdatatable' version '1.1.0'
    * package encoding: UTF-8
    * checking CRAN incoming feasibility ... Note_to_CRAN_maintainers
    Maintainer: 'John Mount <jmount@win-vector.com>'
    Status: OK

## Reverse dependencies

    All reverse dependencies check okay.
    
    devtools::revdep_check()
    Checking 2 packages: cdata, vtreat
    Checked cdata : 0 errors | 0 warnings | 0 notes
    Checked vtreat: 0 errors | 0 warnings | 0 notes


Note: Codd is spelled correctly.

