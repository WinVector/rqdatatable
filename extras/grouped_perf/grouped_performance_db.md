grouped\_performance\_db
================

Read example data and expected result.

``` r
set.seed(2020)

d <- read.csv(file = gzfile("d.csv.gz"), 
              stringsAsFactors = FALSE, 
              strip.white = TRUE)
expect <- read.csv(file = gzfile("res.csv.gz"), 
              stringsAsFactors = FALSE, 
              strip.white = TRUE)
```

Example processing, `rquery`.

``` r
library(rquery)
packageVersion("rquery")
```

    ## [1] '1.4.1'

``` r
ops_rquery <- local_td(d, name = 'd') %.>%
  extend(.,
         rn %:=% row_number(),
         cs %:=% cumsum(x),
         partitionby = 'g',
         orderby = 'x') %.>%
  order_rows(.,
             c('g', 'x'))

cat(format(ops_rquery))
```

    ## mk_td("d", c(
    ##   "x",
    ##   "g")) %.>%
    ##  extend(.,
    ##   rn := row_number(),
    ##   cs := cumsum(x),
    ##   partitionby = c('g'),
    ##   orderby = c('x'),
    ##   reverse = c()) %.>%
    ##  order_rows(.,
    ##   c('g', 'x'),
    ##   reverse = c(),
    ##   limit = NULL)

(Note, we could use `:=` for assignment if we imported `rquery` or
`wrapr`, but we are avoiding that to avoid colliding with `data.table`’s
or `dplyr`’s use of the symbol.)

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
    ##   `x`,
    ##   `g`,
    ##   row_number ( ) OVER (  PARTITION BY `g` ORDER BY `x` ) AS `rn`,
    ##   SUM ( `x` ) OVER (  PARTITION BY `g` ORDER BY `x` ) AS `cs`
    ##  FROM (
    ##   SELECT
    ##    `x`,
    ##    `g`
    ##   FROM
    ##    `d`
    ##   ) tsql_51827105674714532633_0000000000
    ## ) tsql_51827105674714532633_0000000001 ORDER BY `g`, `x`

``` r
f_rquery <- function(d) {
  rquery::rq_copy_to(db, "d", d, 
                     temporary = TRUE, overwrite = TRUE)
  res <- execute(db, ops_rquery)
  return(res)
}


res_rquery <- f_rquery(d)

knitr::kable(head(res_rquery))
```

|           x | g                | rn |          cs |
| ----------: | :--------------- | -: | ----------: |
| \-0.9203975 | level\_000000002 |  1 | \-0.9203975 |
|   0.5372110 | level\_000000003 |  1 |   0.5372110 |
|   0.7349189 | level\_000000004 |  1 |   0.7349189 |
| \-0.8907554 | level\_000000005 |  1 | \-0.8907554 |
|   1.7029350 | level\_000000008 |  1 |   1.7029350 |
| \-0.6675965 | level\_000000010 |  1 | \-0.6675965 |

``` r
stopifnot(all.equal(data.frame(res_rquery), data.frame(expect)))
```

Example processing, `dbplyr`.

``` r
library(dplyr)
```

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

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

    ## [1] '0.8.3'

``` r
packageVersion("dbplyr")
```

    ## [1] '1.4.2'

``` r
ops_dbplyr <- tbl(raw_connection, "d") %>%
  arrange(g, x) %>%
  group_by(g) %>%
  mutate(
    rn = row_number(),
    cs = cumsum(x)) %>%
  ungroup()

show_query(ops_dbplyr)
```

    ## <SQL>
    ## SELECT `x`, `g`, ROW_NUMBER() OVER (PARTITION BY `g` ORDER BY `g`, `x`) AS `rn`, SUM(`x`) OVER (PARTITION BY `g` ORDER BY `g`, `x` ROWS UNBOUNDED PRECEDING) AS `cs`
    ## FROM (SELECT *
    ## FROM `d`
    ## ORDER BY `g`, `x`)

``` r
f_dbplyr <- function(d) {
  dplyr::copy_to(raw_connection, df=d, name="d", 
                     temporary = TRUE, overwrite = TRUE)
  res <- compute(ops_dbplyr)
  return(res)
}

res_dbplyr <- f_dbplyr(d)

knitr::kable(head(res_dbplyr))
```

|           x | g                | rn |          cs |
| ----------: | :--------------- | -: | ----------: |
| \-0.9203975 | level\_000000002 |  1 | \-0.9203975 |
|   0.5372110 | level\_000000003 |  1 |   0.5372110 |
|   0.7349189 | level\_000000004 |  1 |   0.7349189 |
| \-0.8907554 | level\_000000005 |  1 | \-0.8907554 |
|   1.7029350 | level\_000000008 |  1 |   1.7029350 |
| \-0.6675965 | level\_000000010 |  1 | \-0.6675965 |

``` r
stopifnot(all.equal(data.frame(res_dbplyr), data.frame(expect)))
```

``` r
library(microbenchmark)

microbenchmark(
  dbplyr = f_dbplyr(d),
  rquery = f_rquery(d),
  times = 5L)
```

    ## Unit: seconds
    ##    expr      min       lq    mean   median       uq      max neval
    ##  dbplyr 4.361953 4.447865 4.49603 4.493744 4.579407 4.597182     5
    ##  rquery 6.280138 6.450251 6.55844 6.457705 6.674456 6.929649     5

``` r
DBI::dbDisconnect(raw_connection)
```
