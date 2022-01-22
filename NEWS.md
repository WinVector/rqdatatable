
# rqdatatable 1.3.1 2022/01/22

 * Fix misuse of rank().

# rqdatatable 1.3.0 2021/06/11

 * Remove LazyData decl.
 
# rqdatatable 1.2.9 2020/10/17

 * Move to tinytest.

# rqdatatable 1.2.8 2020/08/12

 * Documentation updates.
 * Add more related work links.

# rqdatatable 1.2.7 2020/02/11

 * Move wrapr to Depends.
 * Delete some unsuable as-functions.
 * Fix up documentation relative to ex_data_table_step.

# rqdatatable 1.2.6 2020/01/29

 * Return data.frame if we start with data.frame.
 * Belt and suspenders on stringsAsFactors

# rqdatatable 1.2.5 2020/01/12

 * Neaten up package startup.
 
# rqdatatable 1.2.4 2019/11/12

 * Remove unused methods import.
 * More tests on drop_columns.
 * Catch degenerate project.
 
# rqdatatable 1.2.3 2019/10/23

 * Correct how we remove columns to use proper data.table notation.
 * Add group id command: ngroup().
 * Remove unary function adaptors.

# rqdatatable 1.2.2 2019/09/13

 * Fix dotdotdot environment copy issue.
 * Import more from rquery, and ready executor in more cases.

# rqdatatable 1.2.1 2019/08/26

 * Update docs.

# rqdatatable 1.2.0 2019/08/19

 * Move to new f_db signature.
 * Adjust license.

# rqdatatable 1.1.9 2019/07/04

 * Use non-strict let().
 * Support no-new column project().
 * Unify more expression handling.

# rqdatatable 1.1.8 2019/06/01

 * Work with non-tame column names more places.

# rqdatatable 1.1.7 2019/05/14

 * Undo issues from last global env fix.
 
# rqdatatable 1.1.6 2019/05/13

 * Fix some global env references.

# rqdatatable 1.1.5 2019/04/24

 * Re-export basic pivot capability.

# rqdatatable 1.1.4 2019/02/24

 * extra copy in ex_data_table.relop_list() (just in case).
 
# rqdatatable 1.1.3 2019/02/17

 * Move to RUnit.
 * More tests.
 * Add ex_data_table.relop_list().

# rqdatatable 1.1.2 2018/12/17

 * Allow more control of ordering in extend.
 * Relax column production check.
 * Add rq_ufn().
 * More of force parent.frame forcing.
 * Add row limit to order.
 * Add order_expr.
 * Add power test.

# rqdatatable 1.1.1 2018/09/20

  * alternate data.table implementation path.
  * force parent.frame.

# rqdatatable 1.0.0 2018/09/10

  * allow no group columns project.
  * work on ordering in extend.

# rqdatatable 0.1.4 2018/08/18

  * More tests.
  * Work on result print-visibility.

# rqdatatable 0.1.3 2018/07/28

  * Fix full join print glitch.
  * data.table implementation of theta-join.
  * Documentation fixes.

# rqdatatable 0.1.2 2018/07/08

  * Adapt to instant execution path.
  * Don't expect %>>%.
  * Documentation improvements.

# rqdatatable 0.1.1 2018/06/26

  * Don't use isFALSE() (new to R 3.5.0).
  * Update install instructions.
  * Improve regexps.

# rqdatatable 0.1.0 2018/06/18

  * First CRAN release.


