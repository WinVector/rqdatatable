


## Test environments

###  OSX (local machine using --as-cran from the command line)

    R CMD check --as-cran rqdatatable_1.2.3.tar.gz
    * using R version 3.5.0 (2018-04-23)
    * using platform: x86_64-apple-darwin15.6.0 (64-bit)
    * using session charset: UTF-8
    * using option ‘--as-cran’
    * checking for file ‘rqdatatable/DESCRIPTION’ ... OK
    * checking extension type ... Package
    * this is package ‘rqdatatable’ version ‘1.2.3’
    * package encoding: UTF-8
    * checking CRAN incoming feasibility ... Note_to_CRAN_maintainers
    Maintainer: ‘John Mount <jmount@win-vector.com>’
    Status: OK

### Linux

    rhub::check_for_cran()
    1552#> * using R Under development (unstable) (2019-10-20 r77320)
    1553#> * using platform: x86_64-pc-linux-gnu (64-bit)
    1554#> * using session charset: UTF-8
    1555#> * using option ‘--as-cran’
    1556#> * checking for file ‘rqdatatable/DESCRIPTION’ ... OK
    1557#> * checking extension type ... Package
    1558#> * this is package ‘rqdatatable’ version ‘1.2.3’
    1559#> * package encoding: UTF-8
    1560#> * checking CRAN incoming feasibility ...NB: need Internet access to use CRAN incoming checks
    1561#> NOTE
    1562#> Maintainer: ‘John Mount ’
    1563#> Possibly mis-spelled words in DESCRIPTION:
    1564#> Codd (11:44, 12:49)
    1621#> Status: 1 NOTE
    The note is a property of the test environment, not the package.

    rhub::check_for_cran()
    1525#> * using R version 3.6.1 (2019-07-05)
    1526#> * using platform: x86_64-pc-linux-gnu (64-bit)
    1527#> * using session charset: UTF-8
    1528#> * using option ‘--as-cran’
    1529#> * checking for file ‘rqdatatable/DESCRIPTION’ ... OK
    1530#> * checking extension type ... Package
    1531#> * this is package ‘rqdatatable’ version ‘1.2.3’
    1532#> * package encoding: UTF-8
    1533#> * checking CRAN incoming feasibility ... Note_to_CRAN_maintainers
    1534#> Maintainer: ‘John Mount ’
    1589#> Status: OK
    
 
## Reverse dependencies

    Checked reverse dependencies ( https://github.com/WinVector/rqdatatable/blob/master/extras/check_reverse_dependencies.md ).


Note: Codd is spelled correctly.

