
## Test environments

    * OSX (local machine using --as-cran from the command line)
    * using R version 3.5.0 (2018-04-23)
    * using platform: x86_64-apple-darwin15.6.0 (64-bit)

    * Windows ( win-builder.r-project.org uses --as-cran )
 
## R CMD check results

    R CMD check --as-cran rqdatatable_0.1.2.tar.gz 
    
    * checking for file ‘rqdatatable/DESCRIPTION’ ... OK
    * checking extension type ... Package
    * this is package ‘rqdatatable’ version ‘0.1.2’
    * package encoding: UTF-8
    * checking CRAN incoming feasibility ... Note_to_CRAN_maintainers
    Maintainer: ‘John Mount <jmount@win-vector.com>’
    Status: OK


## Reverse dependencies

    All reverse dependencies check okay.
    
    devtools::revdep_check()
    Checking 1 packages: vtreat
    Checked vtreat: 0 errors | 0 warnings | 0 notes

Note: Codd is spelled correctly.

