


## Test environments

###  OSX (local machine using --as-cran from the command line)

    R CMD check --as-cran rqdatatable_1.1.8.tar.gz
    * using R version 3.6.0 (2019-04-26)
    * using platform: x86_64-apple-darwin15.6.0 (64-bit)
    * using session charset: UTF-8
    * using option ‘--as-cran’
    * checking for file ‘rqdatatable/DESCRIPTION’ ... OK
    * checking extension type ... Package
    * this is package ‘rqdatatable’ version ‘1.1.8’
    * package encoding: UTF-8
    * checking CRAN incoming feasibility ... Note_to_CRAN_maintainers
    Maintainer: ‘John Mount <jmount@win-vector.com>’
    Status: OK


### Windows 

    devtools::build_win()
    
    * using log directory 'd:/RCompile/CRANguest/R-release/rqdatatable.Rcheck'
    * using R version 3.6.0 (2019-04-26)
    * using platform: x86_64-w64-mingw32 (64-bit)
    Status: OK
    
    * using log directory 'd:/RCompile/CRANguest/R-devel/rqdatatable.Rcheck'
    * using R Under development (unstable) (2019-05-30 r76623)
    * using platform: x86_64-w64-mingw32 (64-bit)
    Status: OK

## Reverse dependencies

    No strong reverse dependencies ( https://github.com/WinVector/rqdatatable/blob/master/extras/check_reverse_dependencies.md ).

Note: Codd is spelled correctly.

