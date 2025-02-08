# lite-containers

A collection of containers implemented in pure Ruby. 

- `Heap` uses the well-known heap algorithm. The heap contract 
guarantees that the highest ranking element is always on top 
- `SortedArray` uses built-in quick sort and binary search to 
 keep elements ordered
- `AvlTree` keeps elements in a self-balancing binary search tree

## Common features
All containers have the following in common:
- `empty?` and `size` methods to query the size 
(along with the synonyms: `length`, `count`)
- the `drain!` method that empties the container and 
returns all elements in descending order (top priority first).

## Constructor parameters
To keep elements sorted the containers need certain parameters
and helpers provided by the client code.
- First parameter to the constructor is always `type`, taking values
of `min` and `max`, telling the container how to interpret priority.
- `key_extractor` is a proc that receives an element and produces 
the key used for sorting. When key extractor is `nil`, the 
value itself is considered the sort key.
- Sorted array and AVL tree can only operate on unique
entries. Their constructors expect `merge` parameter 
to supply a merge strategy. Allowed values are `:replace`, `:keep` 
or a proc that performs the merge. The proc should take two elements 
as parameters and return a single one. The default strategy 
for both containers is `:replace` meaning that in presence of duplicates 
the new element replaces the old one.

Helpers must honor the following rules for the containers
to maintain consistent sort order:
- The key extractor must always return the same key for the same value
- The new merged element must resolve to the same key
as the original two.

Containers do not enforce these rules; it is the responsibility 
of the client code to provide correctly implemented helpers.

## Heap
Heap is the simplest of the three containers in this library. 
It supports `push`/`<<` method that inserts an element, `top` to
return the top priority element, and `pop` to remove the top priority
element. 

```ruby rspec heap
require 'lite/containers/heap'

heap = Lite::Containers::Heap.instance(:max)
heap << 5 << 1 << 3

expect(heap.top).to eq(5)
expect(heap.pop).to eq(5)
expect(heap.drain!).to eq([3, 1])
```

## Sorted array
Useful for maintaining relatively stable lists that either never change 
or change infrequently. Each insert or delete will reallocate 
the underlying array making it really inefficient 
when the churn is high.

Depending on the nature of the data, different constructors 
can be used to build the sorted array. If the
data come in random order it is necessary to call `from_unsorted`
to have the container sort them.
If the data are already sorted, `from_sorted` could be used, 
or even `from_sorted_unsafe`. The former checks whether the data 
are properly sorted and raises an error when it discovers 
unexpected ordering. The second one performs no check on 
the data leaving that responsibility to the client code.

Sorted array includes the `Enumerable` module, giving
access to all its methods like `map`, `reduce` etc.


```ruby rspec sorted_array
require 'lite/containers/sorted_array'

sorted_array = Lite::Containers::SortedArray.from_unsorted(
  :max,
  [{ income: 0, tax: 15 }, { income: 120_000, tax: 25 }, { income: 60_000, tax: 20 }],
  key_extractor: proc { |elem| elem[:income] }
)

expect(sorted_array.front).to eq({ income: 120_000, tax: 25 })
expect(sorted_array.back).to eq({ income: 0, tax: 15 })
expect(sorted_array.find(60_000)).to eq({ income: 60_000, tax: 20 })
expect(sorted_array.find_or_nearest_forwards(80_000)).to eq({ income: 120_000, tax: 25 })
expect(sorted_array.find_or_nearest_backwards(80_000)).to eq({ income: 60_000, tax: 20 })
```

## AVL tree
Comes in two flavors – `ImplicitKey` and `ExplicitKey`.

- `ImplicitKey` implements `push`/`<<` with single parameter – the element. 
It may need a *key extractor* to be supplied.

```ruby rspec avl_tree_implicit
require 'lite/containers/avl_tree'

tree = Lite::Containers::AvlTree::ImplicitKey.instance(
  :max,
  key_extractor: proc { |elem| elem[:time] }
)

tree << { time: 0, t: 30 } << { time: 45, t: 600 } << { time: 60, t: 800 } << { time: 120, t: 750 }

expect(tree.front).to eq({ time: 120, t: 750 })
expect(tree.back).to eq({ time: 0, t: 30 })
expect(tree.find(45)).to eq({ time: 45, t: 600 })
expect(tree.find_or_nearest_forwards(55)).to eq({ time: 60, t: 800 })
expect(tree.find_or_nearest_backwards(55)).to eq({ time: 45, t: 600 })
```

- `ExplicitKey` implements `insert` that takes two parameters – the key and the value.
Methods like `front`, `back`, `find` etc. return a key/value tuple instead 
of a single element.

```ruby rspec avl_tree_explicit
require 'lite/containers/avl_tree'

tree = Lite::Containers::AvlTree::ExplicitKey.instance(
  :min,
  merge: proc { |old, fresh| { count: old[:count] + fresh[:count] } }
)

tree.insert(0, { count: 1 })
    .insert(10, { count: 1 })
    .insert(10, { count: 1 })
    .insert(20, { count: 1 })
    .insert(30, { count: 1 })

expect(tree.pop_front).to eq([0, { count: 1 }])
expect(tree.pop_back).to eq([30, { count: 1 }])
expect(tree.drain!).to eq([[10, { count: 2 }], [20, { count: 1 }]])
```

AVL tree also includes the `Enumerable` module.

## License
This library is published under MIT license
