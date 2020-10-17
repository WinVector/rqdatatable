
test_relop_project <- function() {

 dL <- build_frame(
   "subjectID", "surveyCategory"     , "assessmentTotal" |
     1          , "withdrawal behavior", 5                 |
     1          , "positive re-framing", 2                 |
     2          , "withdrawal behavior", 3                 |
     2          , "positive re-framing", 4                 )
 test_p <- local_td(dL) %.>%
   project_nse(.,
               maxscore = max(assessmentTotal),
               groupby = 'subjectID')
 r <- ex_data_table(test_p)
 expect <- wrapr::build_frame(
    "subjectID"  , "maxscore" |
       1          , 5          |
       2          , 4          )
 expect_true(wrapr::check_equiv_frames(expect, r))

 test_p2 <- local_td(dL) %.>%
    project_nse(.,
                groupby = 'subjectID')
 r2 <- ex_data_table(test_p2)
 expect2 <- wrapr::build_frame(
    "subjectID" |
       1           |
       2           )
 expect_true(wrapr::check_equiv_frames(expect2, r2))

 invisible(NULL)
}

test_relop_project()

