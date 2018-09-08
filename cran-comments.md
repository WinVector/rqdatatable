
## Test environments

    * OSX (local machine using --as-cran from the command line)
    * using R version 3.5.0 (2018-04-23)
    * using platform: x86_64-apple-darwin15.6.0 (64-bit)

    * Windows ( win-builder.r-project.org uses --as-cran )
    * using R Under development (unstable) (2018-09-07 r75257)
    * using platform: x86_64-w64-mingw32 (64-bit)


## R CMD check results

    R CMD check --as-cran rqdatatable_1.0.0.tar.gz

    * using option ‘--as-cran’
    * checking for file ‘rqdatatable/DESCRIPTION’ ... OK
    * checking extension type ... Package
    * this is package ‘rqdatatable’ version ‘1.0.0’
    * package encoding: UTF-8
    * checking CRAN incoming feasibility ... Note_to_CRAN_maintainers
    Maintainer: ‘John Mount <jmount@win-vector.com>’
    Status: OK


## Reverse dependencies

    All reverse dependencies check okay.
    
    devtools::revdep_check()
    Checking 2 packages: cdata, vtreat
    Checked cdata : 0 errors | 0 warnings | 0 notes
    Checked vtreat: 0 errors | 0 warnings | 0 notes

Note: Codd is spelled correctly.

