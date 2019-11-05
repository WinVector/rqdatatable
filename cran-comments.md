


## Test environments

###  OSX (local machine using --as-cran from the command line)

    R CMD check --as-cran rqdatatable_1.2.4.tar.gz
    * using R version 3.6.0 (2019-04-26)
    * using platform: x86_64-apple-darwin15.6.0 (64-bit)
    * using session charset: UTF-8
    * using option ‘--as-cran’
    * checking for file ‘rqdatatable/DESCRIPTION’ ... OK
    * checking extension type ... Package
    * this is package ‘rqdatatable’ version ‘1.2.4’
    * package encoding: UTF-8
    * checking CRAN incoming feasibility ... NOTE
    Maintainer: ‘John Mount <jmount@win-vector.com>’
    Number of updates in past 6 months: 7
    Status: 1 NOTE

### Linux

    rhub::check_for_cran()

    The note is a property of the test environment, not the package.
 
## Reverse dependencies

    Checked reverse dependencies ( https://github.com/WinVector/rqdatatable/blob/master/extras/check_reverse_dependencies.md ).


Note: Codd is spelled correctly.

