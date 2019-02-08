
test_relop_natural_join <- function() {

 d1 <- build_frame(
     "key", "val", "val1" |
       "a"  , 1  ,  10    |
       "b"  , 2  ,  11    |
       "c"  , 3  ,  12    )
 d2 <- build_frame(
     "key", "val", "val2" |
       "a"  , 5  ,  13    |
       "b"  , 6  ,  14    |
       "d"  , 7  ,  15    )

 # key matching join
 optree <- natural_join(local_td(d1), local_td(d2),
                        jointype = "FULL", by = 'key')
 res1 <- ex_data_table(optree)
 RUnit::checkTrue(data.table::is.data.table(res1))

 # full cross-product join
 # (usually with jointype = "FULL", but "LEFT" is more
 # compatible with rquery field merg semantics).
 optree2 <- natural_join(local_td(d1), local_td(d2),
                         jointype = "LEFT", by = NULL)
 res2 <- ex_data_table(optree2)[]
 # notice ALL non-"by" fields take coalese to left table.
 RUnit::checkTrue(data.table::is.data.table(res2))

 invisible(NULL)
}
