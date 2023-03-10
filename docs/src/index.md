```@meta
CurrentModule = Finch
```

# Finch

[Finch](https://github.com/willow-ahrens/Finch.jl) is an adaptable compiler for
loop nests over structured arrays. Finch can specialize to tensors with runs of
repeated values, or to tensors which are sparse (mostly zero). Finch supports
general sparsity as well as many specialized sparsity patterns, like clustered
nonzeros, diagonals, or triangles.  In addition to zero, Finch supports
optimizations over arbitrary fill values and operators.

At it's heart, Finch is powered by a domain specific language for coiteration,
breaking structured iterators into units we call Looplets. The Looplets are
lowered progressively, leaving several opportunities to rewrite and simplify
intermediate expressions.

## Installation:

```julia
julia> using Pkg; Pkg.add("Finch")
```

## Usage:

We're working on adding more documentation, for now take a look at the
[benchmarks](https://github.com/willow-ahrens/Finch.jl/blob/main/benchmark/benchmarks.jl)
for a few example algorithms.