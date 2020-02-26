```python
import sqlite3

import timeit

import pandas

from data_algebra.data_ops import *
import data_algebra.SQLite
import data_algebra.test_util
```

Load example


```python
d = pandas.read_csv('d.csv.gz')
vars = [c for c in d.columns if not c == 'g']

d.head()
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>g</th>
      <th>v_00001</th>
      <th>v_00002</th>
      <th>v_00003</th>
      <th>v_00004</th>
      <th>v_00005</th>
      <th>v_00006</th>
      <th>v_00007</th>
      <th>v_00008</th>
      <th>v_00009</th>
      <th>v_00010</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>level_000746732</td>
      <td>0.501391</td>
      <td>-0.042046</td>
      <td>0.907852</td>
      <td>1.103653</td>
      <td>-0.933225</td>
      <td>1.991693</td>
      <td>-0.154361</td>
      <td>-0.991363</td>
      <td>2.328447</td>
      <td>0.222225</td>
    </tr>
    <tr>
      <th>1</th>
      <td>level_000424470</td>
      <td>0.512520</td>
      <td>-0.536119</td>
      <td>-0.827670</td>
      <td>-1.587808</td>
      <td>-0.047809</td>
      <td>0.437973</td>
      <td>-0.388076</td>
      <td>-0.227378</td>
      <td>0.454036</td>
      <td>0.340655</td>
    </tr>
    <tr>
      <th>2</th>
      <td>level_000463169</td>
      <td>-1.248967</td>
      <td>-1.006886</td>
      <td>0.352715</td>
      <td>0.847306</td>
      <td>1.417280</td>
      <td>-1.852341</td>
      <td>0.526444</td>
      <td>0.051136</td>
      <td>-0.053652</td>
      <td>1.893562</td>
    </tr>
    <tr>
      <th>3</th>
      <td>level_000025764</td>
      <td>1.093854</td>
      <td>-0.975188</td>
      <td>0.358386</td>
      <td>0.381903</td>
      <td>0.513759</td>
      <td>0.710493</td>
      <td>0.100913</td>
      <td>-0.588443</td>
      <td>-0.159640</td>
      <td>-0.923627</td>
    </tr>
    <tr>
      <th>4</th>
      <td>level_000630470</td>
      <td>0.319834</td>
      <td>-0.073545</td>
      <td>1.457324</td>
      <td>-1.507512</td>
      <td>-0.670575</td>
      <td>-0.870075</td>
      <td>-0.131663</td>
      <td>-0.452909</td>
      <td>1.415066</td>
      <td>-2.134600</td>
    </tr>
  </tbody>
</table>
</div>




```python
d.shape
```




    (1000000, 11)



Set timing reps


```python
reps = 5
```

data_algebra pandas solution


```python
ops = describe_table(d, table_name='d'). \
    extend({'max_' + v: v + '.max()' for v in vars},
        partition_by=['g']). \
    order_rows(['g'] + vars)

ops    
```




    TableDescription(
     table_name='d',
     column_names=[
       'g', 'v_00001', 'v_00002', 'v_00003', 'v_00004', 'v_00005', 'v_00006',  
     'v_00007', 'v_00008', 'v_00009', 'v_00010']) .\
       extend({
        'max_v_00001': 'v_00001.max()',
        'max_v_00002': 'v_00002.max()',
        'max_v_00003': 'v_00003.max()',
        'max_v_00004': 'v_00004.max()',
        'max_v_00005': 'v_00005.max()',
        'max_v_00006': 'v_00006.max()',
        'max_v_00007': 'v_00007.max()',
        'max_v_00008': 'v_00008.max()',
        'max_v_00009': 'v_00009.max()',
        'max_v_00010': 'v_00010.max()'},
       partition_by=['g']) .\
       order_rows(['g', 'v_00001', 'v_00002', 'v_00003', 'v_00004', 'v_00005', 'v_00006', 'v_00007', 'v_00008', 'v_00009', 'v_00010'])




```python
res = ops.transform(d)

res.head()
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>g</th>
      <th>v_00001</th>
      <th>v_00002</th>
      <th>v_00003</th>
      <th>v_00004</th>
      <th>v_00005</th>
      <th>v_00006</th>
      <th>v_00007</th>
      <th>v_00008</th>
      <th>v_00009</th>
      <th>...</th>
      <th>max_v_00001</th>
      <th>max_v_00002</th>
      <th>max_v_00003</th>
      <th>max_v_00004</th>
      <th>max_v_00005</th>
      <th>max_v_00006</th>
      <th>max_v_00007</th>
      <th>max_v_00008</th>
      <th>max_v_00009</th>
      <th>max_v_00010</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>level_000000002</td>
      <td>0.480053</td>
      <td>0.556812</td>
      <td>-0.295186</td>
      <td>1.069603</td>
      <td>-1.287380</td>
      <td>-0.343787</td>
      <td>-0.555874</td>
      <td>0.481993</td>
      <td>-0.085779</td>
      <td>...</td>
      <td>0.480053</td>
      <td>0.556812</td>
      <td>-0.295186</td>
      <td>1.069603</td>
      <td>-1.287380</td>
      <td>-0.343787</td>
      <td>-0.555874</td>
      <td>0.481993</td>
      <td>-0.085779</td>
      <td>-1.203414</td>
    </tr>
    <tr>
      <th>1</th>
      <td>level_000000003</td>
      <td>-0.052534</td>
      <td>0.983563</td>
      <td>0.145466</td>
      <td>1.153262</td>
      <td>-0.102269</td>
      <td>0.593555</td>
      <td>-0.437793</td>
      <td>-0.052661</td>
      <td>1.365170</td>
      <td>...</td>
      <td>-0.052534</td>
      <td>0.983563</td>
      <td>0.145466</td>
      <td>1.153262</td>
      <td>-0.102269</td>
      <td>0.593555</td>
      <td>-0.437793</td>
      <td>-0.052661</td>
      <td>1.365170</td>
      <td>1.840541</td>
    </tr>
    <tr>
      <th>2</th>
      <td>level_000000004</td>
      <td>0.114769</td>
      <td>-0.228287</td>
      <td>-0.739238</td>
      <td>0.681996</td>
      <td>-0.476465</td>
      <td>-0.815794</td>
      <td>0.426362</td>
      <td>0.308667</td>
      <td>-0.685185</td>
      <td>...</td>
      <td>1.302818</td>
      <td>-0.020408</td>
      <td>-0.591229</td>
      <td>0.681996</td>
      <td>0.031225</td>
      <td>0.518879</td>
      <td>0.426362</td>
      <td>0.522919</td>
      <td>0.031270</td>
      <td>0.647587</td>
    </tr>
    <tr>
      <th>3</th>
      <td>level_000000004</td>
      <td>1.302818</td>
      <td>-0.020408</td>
      <td>-0.591229</td>
      <td>-0.453501</td>
      <td>0.031225</td>
      <td>0.518879</td>
      <td>-0.724670</td>
      <td>0.522919</td>
      <td>0.031270</td>
      <td>...</td>
      <td>1.302818</td>
      <td>-0.020408</td>
      <td>-0.591229</td>
      <td>0.681996</td>
      <td>0.031225</td>
      <td>0.518879</td>
      <td>0.426362</td>
      <td>0.522919</td>
      <td>0.031270</td>
      <td>0.647587</td>
    </tr>
    <tr>
      <th>4</th>
      <td>level_000000005</td>
      <td>0.209939</td>
      <td>0.568525</td>
      <td>-0.657119</td>
      <td>1.791830</td>
      <td>1.800427</td>
      <td>-0.123661</td>
      <td>0.084579</td>
      <td>0.057838</td>
      <td>1.047468</td>
      <td>...</td>
      <td>1.017089</td>
      <td>0.568525</td>
      <td>-0.022681</td>
      <td>1.791830</td>
      <td>1.800427</td>
      <td>0.519874</td>
      <td>0.084579</td>
      <td>1.805242</td>
      <td>1.047468</td>
      <td>2.604739</td>
    </tr>
  </tbody>
</table>
<p>5 rows × 21 columns</p>
</div>




```python
expect = pandas.read_csv('res.csv.gz')

expect.head()
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>g</th>
      <th>v_00001</th>
      <th>v_00002</th>
      <th>v_00003</th>
      <th>v_00004</th>
      <th>v_00005</th>
      <th>v_00006</th>
      <th>v_00007</th>
      <th>v_00008</th>
      <th>v_00009</th>
      <th>...</th>
      <th>max_v_00001</th>
      <th>max_v_00002</th>
      <th>max_v_00003</th>
      <th>max_v_00004</th>
      <th>max_v_00005</th>
      <th>max_v_00006</th>
      <th>max_v_00007</th>
      <th>max_v_00008</th>
      <th>max_v_00009</th>
      <th>max_v_00010</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>level_000000002</td>
      <td>0.480053</td>
      <td>0.556812</td>
      <td>-0.295186</td>
      <td>1.069603</td>
      <td>-1.287380</td>
      <td>-0.343787</td>
      <td>-0.555874</td>
      <td>0.481993</td>
      <td>-0.085779</td>
      <td>...</td>
      <td>0.480053</td>
      <td>0.556812</td>
      <td>-0.295186</td>
      <td>1.069603</td>
      <td>-1.287380</td>
      <td>-0.343787</td>
      <td>-0.555874</td>
      <td>0.481993</td>
      <td>-0.085779</td>
      <td>-1.203414</td>
    </tr>
    <tr>
      <th>1</th>
      <td>level_000000003</td>
      <td>-0.052534</td>
      <td>0.983563</td>
      <td>0.145466</td>
      <td>1.153262</td>
      <td>-0.102269</td>
      <td>0.593555</td>
      <td>-0.437793</td>
      <td>-0.052661</td>
      <td>1.365170</td>
      <td>...</td>
      <td>-0.052534</td>
      <td>0.983563</td>
      <td>0.145466</td>
      <td>1.153262</td>
      <td>-0.102269</td>
      <td>0.593555</td>
      <td>-0.437793</td>
      <td>-0.052661</td>
      <td>1.365170</td>
      <td>1.840541</td>
    </tr>
    <tr>
      <th>2</th>
      <td>level_000000004</td>
      <td>0.114769</td>
      <td>-0.228287</td>
      <td>-0.739238</td>
      <td>0.681996</td>
      <td>-0.476465</td>
      <td>-0.815794</td>
      <td>0.426362</td>
      <td>0.308667</td>
      <td>-0.685185</td>
      <td>...</td>
      <td>1.302818</td>
      <td>-0.020408</td>
      <td>-0.591229</td>
      <td>0.681996</td>
      <td>0.031225</td>
      <td>0.518879</td>
      <td>0.426362</td>
      <td>0.522919</td>
      <td>0.031270</td>
      <td>0.647587</td>
    </tr>
    <tr>
      <th>3</th>
      <td>level_000000004</td>
      <td>1.302818</td>
      <td>-0.020408</td>
      <td>-0.591229</td>
      <td>-0.453501</td>
      <td>0.031225</td>
      <td>0.518879</td>
      <td>-0.724670</td>
      <td>0.522919</td>
      <td>0.031270</td>
      <td>...</td>
      <td>1.302818</td>
      <td>-0.020408</td>
      <td>-0.591229</td>
      <td>0.681996</td>
      <td>0.031225</td>
      <td>0.518879</td>
      <td>0.426362</td>
      <td>0.522919</td>
      <td>0.031270</td>
      <td>0.647587</td>
    </tr>
    <tr>
      <th>4</th>
      <td>level_000000005</td>
      <td>0.209939</td>
      <td>0.568525</td>
      <td>-0.657119</td>
      <td>1.791830</td>
      <td>1.800427</td>
      <td>-0.123661</td>
      <td>0.084579</td>
      <td>0.057838</td>
      <td>1.047468</td>
      <td>...</td>
      <td>1.017089</td>
      <td>0.568525</td>
      <td>-0.022681</td>
      <td>1.791830</td>
      <td>1.800427</td>
      <td>0.519874</td>
      <td>0.084579</td>
      <td>1.805242</td>
      <td>1.047468</td>
      <td>2.604739</td>
    </tr>
  </tbody>
</table>
<p>5 rows × 21 columns</p>
</div>




```python
assert data_algebra.test_util.equivalent_frames(res, expect)
```


```python
def f():
    return ops.transform(d)

time_pandas = timeit.timeit(f, number=reps)
time_pandas
```




    116.65613596700001




```python
time_pandas/reps
```




    23.331227193400004



data_algebra modin[ray] solution


```python
import importlib

from data_algebra.modin_model import ModinModel
```


```python
modin_pandas = importlib.import_module("modin.pandas")
data_model = ModinModel(modin_engine='ray')
```


```python
data_map = {'d':  modin_pandas.DataFrame(d)}
```

    UserWarning: Distributing <class 'pandas.core.frame.DataFrame'> object. This may take some time.


Note: modin may not be in parallel mode for many of the steps.


```python
%%capture
res_name = data_model.eval(ops, data_map=data_map)
```


```python
res_modin = data_map[res_name]
res_pandas = data_model.to_pandas(res_modin, data_map=data_map)
assert data_algebra.test_util.equivalent_frames(res_pandas, expect)
```


```python
%%capture
def f_modin():
    data_map = {'d':  modin_pandas.DataFrame(d)}
    data_model.eval(ops, data_map=data_map)

time_modin = timeit.timeit(f_modin, number=reps)
```


```python
time_modin
```




    574.112759528




```python
time_modin/reps
```




    114.8225519056



data_algebra SQL solution


```python
dbmodel = data_algebra.SQLite.SQLiteModel()
```


```python
print(ops.to_sql(dbmodel, pretty=True))
```

    SELECT "g",
           "v_00001",
           "v_00002",
           "v_00003",
           "v_00004",
           "v_00005",
           "v_00006",
           "v_00007",
           "v_00008",
           "v_00009",
           "v_00010",
           "max_v_00001",
           "max_v_00002",
           "max_v_00003",
           "max_v_00004",
           "max_v_00005",
           "max_v_00006",
           "max_v_00007",
           "max_v_00008",
           "max_v_00009",
           "max_v_00010"
    FROM
      (SELECT "g",
              "v_00001",
              "v_00002",
              "v_00003",
              "v_00004",
              "v_00005",
              "v_00006",
              "v_00007",
              "v_00008",
              "v_00009",
              "v_00010",
              MAX("v_00001") OVER (PARTITION BY "g") AS "max_v_00001",
                                  MAX("v_00002") OVER (PARTITION BY "g") AS "max_v_00002",
                                                      MAX("v_00003") OVER (PARTITION BY "g") AS "max_v_00003",
                                                                          MAX("v_00004") OVER (PARTITION BY "g") AS "max_v_00004",
                                                                                              MAX("v_00005") OVER (PARTITION BY "g") AS "max_v_00005",
                                                                                                                  MAX("v_00006") OVER (PARTITION BY "g") AS "max_v_00006",
                                                                                                                                      MAX("v_00007") OVER (PARTITION BY "g") AS "max_v_00007",
                                                                                                                                                          MAX("v_00008") OVER (PARTITION BY "g") AS "max_v_00008",
                                                                                                                                                                              MAX("v_00009") OVER (PARTITION BY "g") AS "max_v_00009",
                                                                                                                                                                                                  MAX("v_00010") OVER (PARTITION BY "g") AS "max_v_00010"
       FROM "d") "extend_1"
    ORDER BY "g",
             "v_00001",
             "v_00002",
             "v_00003",
             "v_00004",
             "v_00005",
             "v_00006",
             "v_00007",
             "v_00008",
             "v_00009",
             "v_00010"



```python
conn = sqlite3.connect(':memory:')
dbmodel.prepare_connection(conn)
```


```python
def f_db():
    try:
        dbmodel.read_query(conn, "DROP TABLE d")
    except:
        pass
    dbmodel.insert_table(conn, d, 'd')
    return dbmodel.read_query(conn, ops.to_sql(dbmodel))
```


```python
res_db = f_db()

assert data_algebra.test_util.equivalent_frames(res_db, expect)
```


```python
time_sql = timeit.timeit(f_db, number=reps)
time_sql
```




    108.49377427799993




```python
time_sql/reps
```




    21.698754855599987



Clean up


```python
# neaten up
conn.close()
```


```python

```
