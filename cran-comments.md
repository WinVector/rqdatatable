
## Test environments

###  OSX (local machine using --as-cran from the command line)

    R CMD check --as-cran rqdatatable_1.3.2.tar.gz
    * using R version 4.3.0 (2023-04-21)
    * using platform: x86_64-apple-darwin20 (64-bit)

### Windows

    devtools::check_win_devel()
    * using R Under development (unstable) (2023-08-12 r84939 ucrt)
    * using platform: x86_64-w64-mingw32

    rhub::check_for_cran()
    562#> * using R Under development (unstable) (2023-07-21 r84722 ucrt)
    563#> * using platform: x86_64-w64-mingw32

### Linux

    rhub::check_for_cran()
    2833#> * using R Under development (unstable) (2023-06-09 r84528)
    2834#> * using platform: x86_64-pc-linux-gnu
    2825#> * using R version 4.3.0 (2023-04-21)
    2826#> * using platform: x86_64-pc-linux-gnu (64-bit)

## Reverse dependencies

    Checked reverse dependencies ( https://github.com/WinVector/rqdatatable/blob/master/extras/check_reverse_dependencies.md ).

Note: Codd is spelled correctly.
