Grouped Performance Demonstration
================

For this example we will look at a per-group maximum calculation over
many rows and a few columns.

First we make the example data.

``` r
set.seed(2020)
nrow <- 1000000
ndcol <- 10

mk_data <- function(nrow, ndcol) {
  d <- data.frame(
    g = sprintf("level_%09g", sample.int(nrow, size = nrow, replace = TRUE)),
    stringsAsFactors = FALSE)
  for(j in seq_len(ndcol)) {
    v <- sprintf("v_%05g", j)
    d[[v]] <- rnorm(nrow)
  }
  return(d)
}

d <- mk_data(nrow, ndcol)
write.csv(d, file = gzfile("d.csv.gz"), quote = FALSE, row.names = FALSE)
vars <- setdiff(colnames(d), 'g')
```

Example processing, `rqdatatable`.

``` r
library(rqdatatable)
```

    ## Loading required package: wrapr

    ## Loading required package: rquery

``` r
packageVersion("rquery")
```

    ## [1] '1.4.5'

``` r
packageVersion("rqdatatable")
```

    ## [1] '1.2.8'

``` r
ops_rquery <- local_td(d, name = 'd') %.>%
  extend_se(.,
         paste0('max_', vars) %:=% paste0('max(', vars, ')'),
         partitionby = 'g') %.>%
  order_rows(.,
             c('g', vars))

cat(format(ops_rquery))
```

    ## mk_td("d", c(
    ##   "g",
    ##   "v_00001",
    ##   "v_00002",
    ##   "v_00003",
    ##   "v_00004",
    ##   "v_00005",
    ##   "v_00006",
    ##   "v_00007",
    ##   "v_00008",
    ##   "v_00009",
    ##   "v_00010")) %.>%
    ##  extend(.,
    ##   max_v_00001 := max(v_00001),
    ##   max_v_00002 := max(v_00002),
    ##   max_v_00003 := max(v_00003),
    ##   max_v_00004 := max(v_00004),
    ##   max_v_00005 := max(v_00005),
    ##   max_v_00006 := max(v_00006),
    ##   max_v_00007 := max(v_00007),
    ##   max_v_00008 := max(v_00008),
    ##   max_v_00009 := max(v_00009),
    ##   max_v_00010 := max(v_00010),
    ##   partitionby = c('g'),
    ##   orderby = c(),
    ##   reverse = c()) %.>%
    ##  order_rows(.,
    ##   c('g', 'v_00001', 'v_00002', 'v_00003', 'v_00004', 'v_00005', 'v_00006', 'v_00007', 'v_00008', 'v_00009', 'v_00010'),
    ##   reverse = c(),
    ##   limit = NULL)

``` r
res_rqdatatable <- d %.>% ops_rquery

knitr::kable(head(res_rqdatatable))
```

| g                |    v\_00001 |    v\_00002 |    v\_00003 |    v\_00004 |    v\_00005 |    v\_00006 |    v\_00007 |    v\_00008 |    v\_00009 |    v\_00010 | max\_v\_00001 | max\_v\_00002 | max\_v\_00003 | max\_v\_00004 | max\_v\_00005 | max\_v\_00006 | max\_v\_00007 | max\_v\_00008 | max\_v\_00009 | max\_v\_00010 |
| :--------------- | ----------: | ----------: | ----------: | ----------: | ----------: | ----------: | ----------: | ----------: | ----------: | ----------: | ------------: | ------------: | ------------: | ------------: | ------------: | ------------: | ------------: | ------------: | ------------: | ------------: |
| level\_000000002 |   0.4800527 |   0.5568117 | \-0.2951862 |   1.0696033 | \-1.2873800 | \-0.3437869 | \-0.5558743 |   0.4819933 | \-0.0857788 | \-1.2034138 |     0.4800527 |     0.5568117 |   \-0.2951862 |     1.0696033 |   \-1.2873800 |   \-0.3437869 |   \-0.5558743 |     0.4819933 |   \-0.0857788 |   \-1.2034138 |
| level\_000000003 | \-0.0525336 |   0.9835632 |   0.1454660 |   1.1532623 | \-0.1022689 |   0.5935545 | \-0.4377926 | \-0.0526614 |   1.3651697 |   1.8405414 |   \-0.0525336 |     0.9835632 |     0.1454660 |     1.1532623 |   \-0.1022689 |     0.5935545 |   \-0.4377926 |   \-0.0526614 |     1.3651697 |     1.8405414 |
| level\_000000004 |   0.1147691 | \-0.2282867 | \-0.7392376 |   0.6819956 | \-0.4764646 | \-0.8157944 |   0.4263617 |   0.3086669 | \-0.6851846 |   0.6475868 |     1.3028178 |   \-0.0204083 |   \-0.5912287 |     0.6819956 |     0.0312253 |     0.5188793 |     0.4263617 |     0.5229186 |     0.0312696 |     0.6475868 |
| level\_000000004 |   1.3028178 | \-0.0204083 | \-0.5912287 | \-0.4535013 |   0.0312253 |   0.5188793 | \-0.7246705 |   0.5229186 |   0.0312696 |   0.2899714 |     1.3028178 |   \-0.0204083 |   \-0.5912287 |     0.6819956 |     0.0312253 |     0.5188793 |     0.4263617 |     0.5229186 |     0.0312696 |     0.6475868 |
| level\_000000005 |   0.2099386 |   0.5685254 | \-0.6571189 |   1.7918295 |   1.8004274 | \-0.1236607 |   0.0845795 |   0.0578379 |   1.0474681 |   0.6233145 |     1.0170890 |     0.5685254 |   \-0.0226812 |     1.7918295 |     1.8004274 |     0.5198738 |     0.0845795 |     1.8052422 |     1.0474681 |     2.6047389 |
| level\_000000005 |   1.0170890 | \-0.1103282 | \-0.0226812 |   1.0350335 | \-1.2260081 |   0.5198738 | \-0.7549627 |   1.8052422 | \-0.7939559 |   2.6047389 |     1.0170890 |     0.5685254 |   \-0.0226812 |     1.7918295 |     1.8004274 |     0.5198738 |     0.0845795 |     1.8052422 |     1.0474681 |     2.6047389 |

``` r
write.csv(res_rqdatatable, file = gzfile("res.csv.gz"), quote = FALSE, row.names = FALSE)
```

Example processing, `base R`.

``` r
f_base <- function(d) {
  d_res <- d
  perm <- do.call(order, as.list(d_res[, c('g', vars), drop= FALSE]))
  d_res <- d_res[perm, , drop=FALSE]
  rownames(d_res) <- NULL
  for(v in vars) {
    agg <- tapply(d_res[[v]], d_res$g, max)
    agg_v <- as.numeric(agg)
    names(agg_v) <- names(agg)
    d_res[[paste0('max_', v)]] = agg_v[d_res$g]
  }
  d_res
}

res_base <- f_base(d)

stopifnot(isTRUE(all.equal(data.frame(res_base), data.frame(res_rqdatatable))))
```

Example processing `rquery/db`.

``` r
packageVersion('DBI')
```

    ## [1] '1.1.0'

``` r
packageVersion('RSQLite')
```

    ## [1] '2.2.0'

``` r
raw_connection <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
RSQLite::initExtension(raw_connection)
db <- rquery_db_info(
  connection = raw_connection,
  is_dbi = TRUE,
  connection_options = rq_connection_tests(raw_connection))

cat(to_sql(ops_rquery, db))
```

    ## SELECT * FROM (
    ##  SELECT
    ##   `g`,
    ##   `v_00001`,
    ##   `v_00002`,
    ##   `v_00003`,
    ##   `v_00004`,
    ##   `v_00005`,
    ##   `v_00006`,
    ##   `v_00007`,
    ##   `v_00008`,
    ##   `v_00009`,
    ##   `v_00010`,
    ##   max ( `v_00001` ) OVER (  PARTITION BY `g` ) AS `max_v_00001`,
    ##   max ( `v_00002` ) OVER (  PARTITION BY `g` ) AS `max_v_00002`,
    ##   max ( `v_00003` ) OVER (  PARTITION BY `g` ) AS `max_v_00003`,
    ##   max ( `v_00004` ) OVER (  PARTITION BY `g` ) AS `max_v_00004`,
    ##   max ( `v_00005` ) OVER (  PARTITION BY `g` ) AS `max_v_00005`,
    ##   max ( `v_00006` ) OVER (  PARTITION BY `g` ) AS `max_v_00006`,
    ##   max ( `v_00007` ) OVER (  PARTITION BY `g` ) AS `max_v_00007`,
    ##   max ( `v_00008` ) OVER (  PARTITION BY `g` ) AS `max_v_00008`,
    ##   max ( `v_00009` ) OVER (  PARTITION BY `g` ) AS `max_v_00009`,
    ##   max ( `v_00010` ) OVER (  PARTITION BY `g` ) AS `max_v_00010`
    ##  FROM (
    ##   SELECT
    ##    `g`,
    ##    `v_00001`,
    ##    `v_00002`,
    ##    `v_00003`,
    ##    `v_00004`,
    ##    `v_00005`,
    ##    `v_00006`,
    ##    `v_00007`,
    ##    `v_00008`,
    ##    `v_00009`,
    ##    `v_00010`
    ##   FROM
    ##    `d`
    ##   ) tsql_54305123256826245803_0000000000
    ## ) tsql_54305123256826245803_0000000001 ORDER BY `g`, `v_00001`, `v_00002`, `v_00003`, `v_00004`, `v_00005`, `v_00006`, `v_00007`, `v_00008`, `v_00009`, `v_00010`

``` r
f_rquery_db <- function(d) {
  rquery::rq_copy_to(db, "d", d, 
                     temporary = TRUE, overwrite = TRUE)
  res <- execute(db, ops_rquery)
  return(res)
}


res_rquery_db <- f_rquery_db(d)

stopifnot(isTRUE(all.equal(data.frame(res_rquery_db), data.frame(res_rqdatatable))))
```

Example processing `data.table`.

``` r
library(data.table)
```

    ## 
    ## Attaching package: 'data.table'

    ## The following object is masked from 'package:wrapr':
    ## 
    ##     :=

``` r
packageVersion("data.table")
```

    ## [1] '1.12.8'

``` r
f_data.table <- function(d) {
  dt <- data.table(d)
  exprs <- paste0('max_', vars, ' = max(', vars, ')')
  stmt <- paste0('dt[, `:=`(', paste(exprs, collapse = ', '), '), by = g]')
  dt <- eval(parse(text=stmt))
  setorderv(dt, c('g', vars))
  return(dt)
}

res_data.table <- f_data.table(d)

stopifnot(isTRUE(all.equal(res_rqdatatable, data.frame(res_data.table))))
```

Example processing, `dplyr`.

``` r
library(dplyr)
```

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:data.table':
    ## 
    ##     between, first, last

    ## The following object is masked from 'package:wrapr':
    ## 
    ##     coalesce

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
library(rlang)
```

    ## 
    ## Attaching package: 'rlang'

    ## The following object is masked from 'package:data.table':
    ## 
    ##     :=

    ## The following object is masked from 'package:wrapr':
    ## 
    ##     :=

``` r
packageVersion("dplyr")
```

    ## [1] '0.8.4'

``` r
exprs <- paste0('max_', vars, ' := max(', vars, ')')
rlang_expr <- eval(parse(text=paste0('exprs(', paste(exprs, collapse = ', '), ')')))
rlang_cols <- syms(c('g', vars))

ops_dplyr <- . %>%
  group_by(g) %>%
  mutate(!!!rlang_expr) %>%
  ungroup() %>%
  arrange(!!!rlang_cols)

res_dplyr <- d %>% ops_dplyr

stopifnot(isTRUE(all.equal(res_rqdatatable, data.frame(res_dplyr))))
```

Example processing, `dbplyr`.

``` r
library(dbplyr)
```

    ## 
    ## Attaching package: 'dbplyr'

    ## The following objects are masked from 'package:dplyr':
    ## 
    ##     ident, sql

``` r
packageVersion("dplyr")
```

    ## [1] '0.8.4'

``` r
ops_dbplyr <- tbl(raw_connection, "d") %>%
  group_by(g) %>%
  mutate(!!!rlang_expr) %>%
  ungroup() %>%
  arrange(!!!rlang_cols)

show_query(ops_dbplyr)
```

    ## <SQL>

    ## Warning: Missing values are always removed in SQL.
    ## Use `MAX(x, na.rm = TRUE)` to silence this warning
    ## This warning is displayed only once per session.

    ## SELECT `g`, `v_00001`, `v_00002`, `v_00003`, `v_00004`, `v_00005`, `v_00006`, `v_00007`, `v_00008`, `v_00009`, `v_00010`, MAX(`v_00001`) OVER (PARTITION BY `g`) AS `max_v_00001`, MAX(`v_00002`) OVER (PARTITION BY `g`) AS `max_v_00002`, MAX(`v_00003`) OVER (PARTITION BY `g`) AS `max_v_00003`, MAX(`v_00004`) OVER (PARTITION BY `g`) AS `max_v_00004`, MAX(`v_00005`) OVER (PARTITION BY `g`) AS `max_v_00005`, MAX(`v_00006`) OVER (PARTITION BY `g`) AS `max_v_00006`, MAX(`v_00007`) OVER (PARTITION BY `g`) AS `max_v_00007`, MAX(`v_00008`) OVER (PARTITION BY `g`) AS `max_v_00008`, MAX(`v_00009`) OVER (PARTITION BY `g`) AS `max_v_00009`, MAX(`v_00010`) OVER (PARTITION BY `g`) AS `max_v_00010`
    ## FROM `d`
    ## ORDER BY `g`, `v_00001`, `v_00002`, `v_00003`, `v_00004`, `v_00005`, `v_00006`, `v_00007`, `v_00008`, `v_00009`, `v_00010`

``` r
f_dbplyr <- function(d) {
  dplyr::copy_to(raw_connection, df=d, name="d", 
                     temporary = TRUE, overwrite = TRUE)
  res <- compute(ops_dbplyr)
  return(res)
}

res_dbplyr <- f_dbplyr(d)

stopifnot(isTRUE(all.equal(data.frame(res_dbplyr), data.frame(res_rqdatatable))))
```

Example processing, `dtplyr`.

``` r
library(dtplyr)
packageVersion("dtplyr")
```

    ## [1] '1.0.1'

``` r
exprs <- paste0('max_', vars, ' := max(', vars, ')')
rlang_expr <- eval(parse(text=paste0('exprs(', paste(exprs, collapse = ', '), ')')))
rlang_cols <- syms(c('g', vars))
  
ops_dtplyr <- . %>%
  lazy_dt() %>%
  group_by(g) %>%
  mutate(!!!rlang_expr) %>%
  ungroup() %>%
  arrange(!!!rlang_cols) %>%
  as_tibble()

res_dtplyr <- d %>% ops_dtplyr
stopifnot(isTRUE(all.equal(res_rqdatatable, data.frame(res_dtplyr))))
```

``` r
library(microbenchmark)

microbenchmark(
  base_R = f_base(d),
  data.table = f_data.table(d),
  dplyr = d %>% ops_dplyr,
  dbplyr = f_dbplyr(d),
  dtplyr = d %>% ops_dtplyr,
  rqdatatable = d %.>% ops_rquery,
  rquery_db = f_rquery_db(d),
  times = 5L)
```

    ## Unit: seconds
    ##         expr       min        lq      mean    median        uq       max neval
    ##       base_R 62.887651 62.923738 63.750470 63.590133 64.425760 64.925069     5
    ##   data.table  6.987237  7.122194  7.477244  7.513078  7.657816  8.105896     5
    ##        dplyr 31.126465 31.162979 31.493564 31.242731 31.489243 32.446402     5
    ##       dbplyr 11.907045 11.926958 12.276748 12.331318 12.588768 12.629650     5
    ##       dtplyr  8.621169  9.160520  9.922092  9.455926 10.583315 11.789530     5
    ##  rqdatatable  7.577565  7.584150  7.844445  7.805707  7.991885  8.262919     5
    ##    rquery_db 14.274705 14.931324 15.387234 15.800935 15.850284 16.078924     5

Details for a small performance comparison run on 2020-02-26.

Machine was an idle Late 2013 Mac Mini running macOS High Sierra
10.13.6, Processor 2.8 GHz Intel Core i5, Memory 8 GB 1600 MHz DDR3.

``` r
R.version
```

    ##                _                           
    ## platform       x86_64-apple-darwin15.6.0   
    ## arch           x86_64                      
    ## os             darwin15.6.0                
    ## system         x86_64, darwin15.6.0        
    ## status                                     
    ## major          3                           
    ## minor          6.2                         
    ## year           2019                        
    ## month          12                          
    ## day            12                          
    ## svn rev        77560                       
    ## language       R                           
    ## version.string R version 3.6.2 (2019-12-12)
    ## nickname       Dark and Stormy Night
