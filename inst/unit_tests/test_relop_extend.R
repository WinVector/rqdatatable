
test_relop_extend <- function() {

  dL <- build_frame(
    "subjectID", "surveyCategory"     , "assessmentTotal", "one" |
      1          , "withdrawal behavior", 5                , 1     |
      1          , "positive re-framing", 2                , 1     |
      2          , "withdrawal behavior", 3                , 1     |
      2          , "positive re-framing", 4                , 1     |
      2          , "other"              , 0                , 1    )

 scale <- 0.237
 rquery_pipeline <- local_td(dL) %.>%
   extend_nse(.,
              probability %:=%
                exp(assessmentTotal * scale)/
                sum(exp(assessmentTotal * scale)),
              count %:=% n(),
              rank %:=% rank(),
              orderby = c("assessmentTotal", "surveyCategory"),
              reverse = c("assessmentTotal"),
              partitionby = 'subjectID')  %.>%
   orderby(., c("subjectID", "probability"))
 res <- ex_data_table(rquery_pipeline, tables = list(dL = dL))
 # cat(draw_frame(res, formatC_options = list(digits = 7)))
 res$probability <- round(res$probability, 4)
 expect <- wrapr::build_frame(
    "subjectID"  , "surveyCategory"     , "assessmentTotal", "one"   , "probability", "count" , "rank"   |
       1   , "positive re-framing",        2         ,        1, 0.3293779    ,        2,        2 |
       1   , "withdrawal behavior",        5         ,        1, 0.6706221    ,        2,        1 |
       2   , "other"              ,        0         ,        1, 0.1780446    ,        3,        3 |
       2   , "withdrawal behavior",        3         ,        1, 0.3625035    ,        3,        2 |
       2   , "positive re-framing",        4         ,        1, 0.4594519    ,        3,        1 )
 expect$probability <- round(expect$probability, 4)
 RUnit::checkTrue(wrapr::check_equiv_frames(expect, res))

 invisible(NULL)
}
