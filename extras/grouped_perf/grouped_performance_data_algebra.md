```python
import pandas
from data_algebra.data_ops import *
```


```python
d = pandas.read_csv('d.csv.gz')

d
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
      <th>x</th>
      <th>g</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>0.376972</td>
      <td>level_000357975</td>
    </tr>
    <tr>
      <th>1</th>
      <td>0.301548</td>
      <td>level_000668062</td>
    </tr>
    <tr>
      <th>2</th>
      <td>-1.098023</td>
      <td>level_000593766</td>
    </tr>
    <tr>
      <th>3</th>
      <td>-1.130406</td>
      <td>level_000203296</td>
    </tr>
    <tr>
      <th>4</th>
      <td>-2.796534</td>
      <td>level_000064605</td>
    </tr>
    <tr>
      <th>...</th>
      <td>...</td>
      <td>...</td>
    </tr>
    <tr>
      <th>999995</th>
      <td>0.154607</td>
      <td>level_000029194</td>
    </tr>
    <tr>
      <th>999996</th>
      <td>-0.241628</td>
      <td>level_000721132</td>
    </tr>
    <tr>
      <th>999997</th>
      <td>0.727351</td>
      <td>level_000698435</td>
    </tr>
    <tr>
      <th>999998</th>
      <td>-1.705844</td>
      <td>level_000237171</td>
    </tr>
    <tr>
      <th>999999</th>
      <td>0.428118</td>
      <td>level_000125022</td>
    </tr>
  </tbody>
</table>
<p>1000000 rows × 2 columns</p>
</div>




```python
ops = describe_table(d, table_name='d'). \
    extend({
        'rn': '_row_number()',
        'cs': 'x.cumsum()'
        },
        partition_by=['g'],
        order_by=['x']). \
    order_rows(['g', 'x'])

ops    
```




    TableDescription(
     table_name='d',
     column_names=[
       'x', 'g']) .\
       extend({
        'rn': '_row_number()',
        'cs': 'x.cumsum()'},
       partition_by=['g'],
       order_by=['x']) .\
       order_rows(['g', 'x'])




```python
res = ops.transform(d)

res
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
      <th>x</th>
      <th>g</th>
      <th>rn</th>
      <th>cs</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>-0.920397</td>
      <td>level_000000002</td>
      <td>1</td>
      <td>-0.920397</td>
    </tr>
    <tr>
      <th>1</th>
      <td>0.537211</td>
      <td>level_000000003</td>
      <td>1</td>
      <td>0.537211</td>
    </tr>
    <tr>
      <th>2</th>
      <td>0.734919</td>
      <td>level_000000004</td>
      <td>1</td>
      <td>0.734919</td>
    </tr>
    <tr>
      <th>3</th>
      <td>-0.890755</td>
      <td>level_000000005</td>
      <td>1</td>
      <td>-0.890755</td>
    </tr>
    <tr>
      <th>4</th>
      <td>1.702935</td>
      <td>level_000000008</td>
      <td>1</td>
      <td>1.702935</td>
    </tr>
    <tr>
      <th>...</th>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
    </tr>
    <tr>
      <th>999995</th>
      <td>1.435739</td>
      <td>level_000999990</td>
      <td>4</td>
      <td>1.569817</td>
    </tr>
    <tr>
      <th>999996</th>
      <td>0.262819</td>
      <td>level_000999993</td>
      <td>1</td>
      <td>0.262819</td>
    </tr>
    <tr>
      <th>999997</th>
      <td>0.081815</td>
      <td>level_000999995</td>
      <td>1</td>
      <td>0.081815</td>
    </tr>
    <tr>
      <th>999998</th>
      <td>1.553806</td>
      <td>level_000999997</td>
      <td>1</td>
      <td>1.553806</td>
    </tr>
    <tr>
      <th>999999</th>
      <td>-0.669694</td>
      <td>level_000999998</td>
      <td>1</td>
      <td>-0.669694</td>
    </tr>
  </tbody>
</table>
<p>1000000 rows × 4 columns</p>
</div>




```python
expect = pandas.read_csv('res.csv.gz')
```


```python
expect
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
      <th>x</th>
      <th>g</th>
      <th>rn</th>
      <th>cs</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>-0.920397</td>
      <td>level_000000002</td>
      <td>1</td>
      <td>-0.920397</td>
    </tr>
    <tr>
      <th>1</th>
      <td>0.537211</td>
      <td>level_000000003</td>
      <td>1</td>
      <td>0.537211</td>
    </tr>
    <tr>
      <th>2</th>
      <td>0.734919</td>
      <td>level_000000004</td>
      <td>1</td>
      <td>0.734919</td>
    </tr>
    <tr>
      <th>3</th>
      <td>-0.890755</td>
      <td>level_000000005</td>
      <td>1</td>
      <td>-0.890755</td>
    </tr>
    <tr>
      <th>4</th>
      <td>1.702935</td>
      <td>level_000000008</td>
      <td>1</td>
      <td>1.702935</td>
    </tr>
    <tr>
      <th>...</th>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
    </tr>
    <tr>
      <th>999995</th>
      <td>1.435739</td>
      <td>level_000999990</td>
      <td>4</td>
      <td>1.569817</td>
    </tr>
    <tr>
      <th>999996</th>
      <td>0.262819</td>
      <td>level_000999993</td>
      <td>1</td>
      <td>0.262819</td>
    </tr>
    <tr>
      <th>999997</th>
      <td>0.081815</td>
      <td>level_000999995</td>
      <td>1</td>
      <td>0.081815</td>
    </tr>
    <tr>
      <th>999998</th>
      <td>1.553806</td>
      <td>level_000999997</td>
      <td>1</td>
      <td>1.553806</td>
    </tr>
    <tr>
      <th>999999</th>
      <td>-0.669694</td>
      <td>level_000999998</td>
      <td>1</td>
      <td>-0.669694</td>
    </tr>
  </tbody>
</table>
<p>1000000 rows × 4 columns</p>
</div>




```python

```


```python
time(ops.transform(d))
```

    CPU times: user 17.7 s, sys: 1.09 s, total: 18.8 s
    Wall time: 15.3 s





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
      <th>x</th>
      <th>g</th>
      <th>rn</th>
      <th>cs</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>-0.920397</td>
      <td>level_000000002</td>
      <td>1</td>
      <td>-0.920397</td>
    </tr>
    <tr>
      <th>1</th>
      <td>0.537211</td>
      <td>level_000000003</td>
      <td>1</td>
      <td>0.537211</td>
    </tr>
    <tr>
      <th>2</th>
      <td>0.734919</td>
      <td>level_000000004</td>
      <td>1</td>
      <td>0.734919</td>
    </tr>
    <tr>
      <th>3</th>
      <td>-0.890755</td>
      <td>level_000000005</td>
      <td>1</td>
      <td>-0.890755</td>
    </tr>
    <tr>
      <th>4</th>
      <td>1.702935</td>
      <td>level_000000008</td>
      <td>1</td>
      <td>1.702935</td>
    </tr>
    <tr>
      <th>...</th>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
    </tr>
    <tr>
      <th>999995</th>
      <td>1.435739</td>
      <td>level_000999990</td>
      <td>4</td>
      <td>1.569817</td>
    </tr>
    <tr>
      <th>999996</th>
      <td>0.262819</td>
      <td>level_000999993</td>
      <td>1</td>
      <td>0.262819</td>
    </tr>
    <tr>
      <th>999997</th>
      <td>0.081815</td>
      <td>level_000999995</td>
      <td>1</td>
      <td>0.081815</td>
    </tr>
    <tr>
      <th>999998</th>
      <td>1.553806</td>
      <td>level_000999997</td>
      <td>1</td>
      <td>1.553806</td>
    </tr>
    <tr>
      <th>999999</th>
      <td>-0.669694</td>
      <td>level_000999998</td>
      <td>1</td>
      <td>-0.669694</td>
    </tr>
  </tbody>
</table>
<p>1000000 rows × 4 columns</p>
</div>




```python
import timeit 

def f():
    return ops.transform(d)

timeit.timeit(f, number=5)
```




    85.533211516




```python

```


```python

```