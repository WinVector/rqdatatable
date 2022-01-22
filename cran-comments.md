
## Test environments

###  OSX (local machine using --as-cran from the command line)

    R CMD check --as-cran rqdatatable_1.3.1.tar.gz 
    * using R version 4.0.2 (2020-06-22)
    * using platform: x86_64-apple-darwin17.0 (64-bit)
    * using session charset: UTF-8
    * using option ‘--as-cran’
    * checking for file ‘rqdatatable/DESCRIPTION’ ... OK
    * checking extension type ... Package
    * this is package ‘rqdatatable’ version ‘1.3.1’
    * package encoding: UTF-8
    * checking CRAN incoming feasibility ... Note_to_CRAN_maintainers
    Maintainer: ‘John Mount <jmount@win-vector.com>’
    ...
    Status: OK

### Windows
    
    rhub::check_for_cran()
    457#> * using R Under development (unstable) (2021-12-17 r81389 ucrt)
    458#> * using platform: x86_64-w64-mingw32 (64-bit)
    459#> * using session charset: UTF-8
    460#> * using option '--as-cran'
    461#> * checking for file 'rqdatatable/DESCRIPTION' ... OK
    462#> * checking extension type ... Package
    463#> * this is package 'rqdatatable' version '1.3.1'
    464#> * package encoding: UTF-8
    465#> * checking CRAN incoming feasibility ... Note_to_CRAN_maintainers
    466#> Maintainer: 'John Mount '
    ...
    520#> * checking for detritus in the temp directory ... NOTE
    521#> Found the following files/directories:
    522#> 'lastMiKTeXException'
    523#> * DONE
    524#> Status: 1 NOTE
    lastMiKTeXException not in package, likely a property of the testing platform.
 
    devtools::check_win_devel()
    ...


### Linux

    rhub::check_for_cran()
    2163#> * using R version 4.1.2 (2021-11-01)
    2164#> * using platform: x86_64-pc-linux-gnu (64-bit)
    2165#> * using session charset: UTF-8
    2166#> * using option ‘--as-cran’
    2167#> * checking for file ‘rqdatatable/DESCRIPTION’ ... OK
    2168#> * checking extension type ... Package
    2169#> * this is package ‘rqdatatable’ version ‘1.3.1’
    2170#> * package encoding: UTF-8
    2171#> * checking CRAN incoming feasibility ... Note_to_CRAN_maintainers
    2172#> Maintainer: ‘John Mount ’
    2229#> Status: OK
    
    rhub::check_for_cran()
    2201#> * using R Under development (unstable) (2022-01-21 r81547)
    2202#> * using platform: x86_64-pc-linux-gnu (64-bit)
    2203#> * using session charset: UTF-8
    2204#> * using option ‘--as-cran’
    2205#> * checking for file ‘rqdatatable/DESCRIPTION’ ... OK
    2206#> * checking extension type ... Package
    2207#> * this is package ‘rqdatatable’ version ‘1.3.1’
    2208#> * package encoding: UTF-8
    2209#> * checking CRAN incoming feasibility ... Note_to_CRAN_maintainers
    2210#> Maintainer: ‘John Mount ’
    2267#> Status: OK

## Reverse dependencies

    Checked reverse dependencies ( https://github.com/WinVector/rqdatatable/blob/master/extras/check_reverse_dependencies.md ).

Note: Codd is spelled correctly.
