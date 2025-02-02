abstract type AbstractFiber{Lvl} <: AbstractTensor end
abstract type AbstractVirtualFiber{Lvl} <: AbstractVirtualTensor end

"""
    Tensor{Lvl} <: AbstractFiber{Lvl}

The multidimensional array type used by `Finch`. `Tensor` is a thin wrapper
around the hierarchical level storage of type `Lvl`.
"""
struct Tensor{Lvl} <: AbstractFiber{Lvl}
    lvl::Lvl
end

"""
    Tensor(lvl)

Construct a `Tensor` using the tensor level storage `lvl`. No initialization of
storage is performed, it is assumed that position 1 of `lvl` corresponds to a
valid tensor, and `lvl` will be wrapped as-is. Call a different constructor to
initialize the storage.
"""
Tensor(lvl::Lvl) where {Lvl<:AbstractLevel} = Tensor{Lvl}(lvl)

"""
    Tensor(lvl, [undef], dims...)

Construct a `Tensor` of size `dims`, and initialize to `undef`, potentially
allocating memory.  Here `undef` is the `UndefInitializer` singleton type.
`dims...` may be a variable number of dimensions or a tuple of dimensions, but
it must correspond to the number of dimensions in `lvl`.
"""
Tensor(lvl::AbstractLevel, dims::Number...) = Tensor(lvl, undef, dims...)
Tensor(lvl::AbstractLevel, dims::Tuple) = Tensor(lvl, undef, dims...)
Tensor(lvl::AbstractLevel, init::UndefInitializer, dims...) = Tensor(assemble!(resize!(lvl, dims...)))
Tensor(lvl::AbstractLevel, init::UndefInitializer, dims::Tuple) = Tensor(assemble!(resize!(lvl, dims...)))
Tensor(lvl::AbstractLevel, init::UndefInitializer) = Tensor(assemble!(lvl))
"""
    Tensor(lvl, arr)

Construct a `Tensor` and initialize it to the contents of `arr`.
To explicitly copy into a tensor,
use @ref[`copyto!`]
"""
Tensor(lvl::AbstractLevel, arr) = dropdefaults!(Tensor(lvl), arr)

"""
    Tensor(arr, [init = zero(eltype(arr))])

Copy an array-like object `arr` into a corresponding, similar `Tensor`
datastructure. Uses `init` as an initial value. May reuse memory when possible.
To explicitly copy into a tensor, use @ref[`copyto!`].

# Examples

```jldoctest
julia> println(summary(Tensor(sparse([1 0; 0 1]))))
2×2 Tensor(Dense(SparseList(Element(0))))

julia> println(summary(Tensor(ones(3, 2, 4))))
3×2×4 Tensor(Dense(Dense(Dense(Element(0.0)))))
```
"""
function Tensor(arr::AbstractArray{Tv, N}, default::Tv=zero(eltype(arr))) where {Tv, N}
    Base.copyto!(Tensor((DenseLevel^(ndims(arr)))(Element{zero(eltype(arr))}())), arr)
end

mutable struct VirtualFiber{Lvl} <: AbstractVirtualFiber{Lvl}
    lvl::Lvl
end

is_injective(ctx, tns::VirtualFiber) = is_level_injective(ctx, tns.lvl)
is_concurrent(ctx, tns::VirtualFiber) = is_level_concurrent(ctx, tns.lvl)[1]

is_atomic(ctx, tns::VirtualFiber) = is_level_atomic(ctx, tns.lvl)

function virtualize(ctx, ex, ::Type{<:Tensor{Lvl}}, tag=freshen(ctx, :tns)) where {Lvl}
    lvl = virtualize(ctx, :($ex.lvl), Lvl, Symbol(tag, :_lvl))
    VirtualFiber(lvl)
end
lower(ctx::AbstractCompiler, fbr::VirtualFiber, ::DefaultStyle) = :(Tensor($(ctx(fbr.lvl))))
FinchNotation.finch_leaf(x::VirtualFiber) = virtual(x)

"""
    SubFiber(lvl, pos)

`SubFiber` represents a tensor at position `pos` within `lvl`.
"""
struct SubFiber{Lvl, Pos} <: AbstractFiber{Lvl}
    lvl::Lvl
    pos::Pos
end

mutable struct VirtualSubFiber{Lvl} <: AbstractVirtualFiber{Lvl}
    lvl::Lvl
    pos
end
function virtualize(ctx, ex, ::Type{<:SubFiber{Lvl, Pos}}, tag=freshen(ctx, :tns)) where {Lvl, Pos}
    lvl = virtualize(ctx, :($ex.lvl), Lvl, Symbol(tag, :_lvl))
    pos = virtualize(ctx, :($ex.pos), Pos)
    VirtualSubFiber(lvl, pos)
end
lower(ctx::AbstractCompiler, fbr::VirtualSubFiber, ::DefaultStyle) = :(SubFiber($(ctx(fbr.lvl)), $(ctx(fbr.pos))))
FinchNotation.finch_leaf(x::VirtualSubFiber) = virtual(x)

@inline Base.ndims(::AbstractFiber{Lvl}) where {Lvl} = level_ndims(Lvl)
@inline Base.ndims(::Type{<:AbstractFiber{Lvl}}) where {Lvl} = level_ndims(Lvl)
@inline Base.size(fbr::AbstractFiber) = level_size(fbr.lvl)
@inline Base.axes(fbr::AbstractFiber) = level_axes(fbr.lvl)
@inline Base.eltype(::AbstractFiber{Lvl}) where {Lvl} = level_eltype(Lvl)
@inline Base.eltype(::Type{<:AbstractFiber{Lvl}}) where {Lvl} = level_eltype(Lvl)
@inline default(::AbstractFiber{Lvl}) where {Lvl} = level_default(Lvl)
@inline default(::Type{<:AbstractFiber{Lvl}}) where {Lvl} = level_default(Lvl)

virtual_size(ctx, tns::AbstractVirtualFiber) = virtual_level_size(ctx, tns.lvl)
function virtual_resize!(ctx, tns::AbstractVirtualFiber, dims...)
    tns.lvl = virtual_level_resize!(ctx, tns.lvl, dims...)
    tns
end
virtual_eltype(tns::AbstractVirtualFiber, ctx) = virtual_level_eltype(tns.lvl)
virtual_default(ctx, tns::AbstractVirtualFiber) = virtual_level_default(tns.lvl)
postype(fbr::AbstractVirtualFiber) = postype(fbr.lvl)
allocator(fbr::AbstractVirtualFiber) = allocator(fbr.lvl)

struct LabelledTree
    key 
    node
end

LabelledTree(node) = LabelledTree(nothing, node)

function Base.show(io::IO, node::LabelledTree)
    if node.key !== nothing
        show(io, something(node.key))
        print(io, ": ")
    end
    labelled_show(io, node.node)
end
labelled_show(io, node) = show(io, node)

AbstractTrees.children(node::LabelledTree) = labelled_children(node.node)
labelled_children(node) = ()

struct CartesianLabel
    idxs
end

cartesian_label(args...) = CartesianLabel(Any[args...])

function Base.show(io::IO, key::CartesianLabel)
    print(io, "[")
    join(io, key.idxs, ", ")
    print(io, "]")
end

struct RangeLabel
    start
    stop
end

range_label(start = nothing, stop = nothing) = RangeLabel(start, stop)

function Base.show(io::IO, key::RangeLabel)
    if key.start !== nothing
        print(io, something(key.start))
    end
    print(io, ":")
    if key.stop !== nothing
        print(io, something(key.stop))
    end
end

function declare!(ctx::AbstractCompiler, fbr::VirtualFiber, init)
    lvl = declare_level!(ctx, fbr.lvl, literal(1), init)
    push!(ctx.code.preamble, assemble_level!(ctx, lvl, literal(1), literal(1))) #TODO this feels unnecessary?
    fbr = VirtualFiber(lvl)
end

function instantiate(ctx::AbstractCompiler, fbr::VirtualFiber, mode, protos)
    return Unfurled(fbr, instantiate(ctx, VirtualSubFiber(fbr.lvl, literal(1)), mode, protos))
end

function virtual_moveto(ctx::AbstractCompiler, fbr::VirtualFiber, arch)
    virtual_moveto_level(ctx, fbr.lvl, arch)
end

function virtual_moveto(ctx::AbstractCompiler, fbr::VirtualSubFiber, arch)
    virtual_moveto_level(ctx, fbr.lvl, arch)
end

struct HollowSubFiber{Lvl, Pos, Dirty} <: AbstractFiber{Lvl}
    lvl::Lvl
    pos::Pos
    dirty::Dirty
end

mutable struct VirtualHollowSubFiber{Lvl}
    lvl::Lvl
    pos
    dirty
end
function virtualize(ctx, ex, ::Type{<:HollowSubFiber{Lvl, Pos, Dirty}}, tag=freshen(ctx, :tns)) where {Lvl, Pos, Dirty}
    lvl = virtualize(ctx, :($ex.lvl), Lvl, Symbol(tag, :_lvl))
    pos = virtualize(ctx, :($ex.pos), Pos)
    dirty = virtualize(ctx, :($ex.dirty), Dirty)
    VirtualHollowSubFiber(lvl, pos, dirty)
end
lower(ctx::AbstractCompiler, fbr::VirtualHollowSubFiber, ::DefaultStyle) = :(HollowSubFiber($(ctx(fbr.lvl)), $(ctx(fbr.pos))))
FinchNotation.finch_leaf(x::VirtualHollowSubFiber) = virtual(x)

function virtual_moveto(ctx::AbstractCompiler, fbr::VirtualHollowSubFiber, arch)
    return VirtualHollowSubFiber(virtual_moveto_level(ctx, fbr.lvl, arch), fbr.pos, fbr.dirty)
end

"""
    redefault!(fbr, init)

Return a tensor which is equal to `fbr`, but with the default (implicit) value
set to `init`.  May reuse memory and render the original tensor unusable when
modified.

```jldoctest
julia> A = Tensor(SparseList(Element(0.0), 10), [2.0, 0.0, 3.0, 0.0, 4.0, 0.0, 5.0, 0.0, 6.0, 0.0])
SparseList (0.0) [1:10]
├─ [1]: 2.0
├─ [3]: 3.0
├─ [5]: 4.0
├─ [7]: 5.0
└─ [9]: 6.0

julia> redefault!(A, Inf)
SparseList (Inf) [1:10]
├─ [1]: 2.0
├─ [3]: 3.0
├─ [5]: 4.0
├─ [7]: 5.0
└─ [9]: 6.0
```
"""
redefault!(fbr::Tensor, init) = Tensor(redefault!(fbr.lvl, init))

"""
    resize!(fbr, dims...)

Set the shape of `fbr` equal to `dims`. May reuse memory and render the original
tensor unusable when modified.
"""
Base.resize!(fbr::Tensor, dims...) = Tensor(resize!(fbr.lvl, dims...))

data_rep(fbr::Tensor) = data_rep(typeof(fbr))
data_rep(::Type{<:AbstractFiber{Lvl}}) where {Lvl} = data_rep_level(Lvl)

function freeze!(ctx::AbstractCompiler, fbr::VirtualFiber)
    return VirtualFiber(freeze_level!(ctx, fbr.lvl, literal(1)))
end

thaw_level!(ctx, lvl, pos) = throw(FinchProtocolError("cannot modify $(typeof(lvl)) in place (forgot to declare with .= ?)"))
function thaw!(ctx::AbstractCompiler, fbr::VirtualFiber)
    return VirtualFiber(thaw_level!(ctx, fbr.lvl, literal(1)))
end

supports_reassembly(lvl) = false

function Base.show(io::IO, fbr::Tensor)
    print(io, "Tensor(", fbr.lvl, ")")
end

function Base.show(io::IO, mime::MIME"text/plain", fbr::Tensor)
    if get(io, :compact, false)
        print(io, "Tensor($(summary(fbr.lvl)))")
    else
        print_tree(io, LabelledTree(SubFiber(fbr.lvl, 1)))
    end
end

function Base.show(io::IO, mime::MIME"text/plain", fbr::VirtualFiber)
    if get(io, :compact, false)
        print(io, "VirtualFiber($(summary(fbr.lvl)))")
    else
        show(io, fbr)
    end
end

function Base.show(io::IO, fbr::SubFiber)
    print(io, "SubFiber(", fbr.lvl, ", ", fbr.pos, ")")
end

function Base.show(io::IO, mime::MIME"text/plain", fbr::SubFiber)
    if get(io, :compact, false)
        print(io, "SubFiber($(summary(fbr.lvl)), $(fbr.pos))")
    else
        print_tree(io, LabelledTree(fbr))
    end
end

function Base.show(io::IO, mime::MIME"text/plain", fbr::VirtualSubFiber)
    if get(io, :compact, false)
        print(io, "VirtualSubFiber($(summary(fbr.lvl)))")
    else
        show(io, fbr)
    end
end

(fbr::Tensor)(idx...) = SubFiber(fbr.lvl, 1)(idx...)

"""
    countstored(arr)

Return the number of stored elements in `arr`. If there are explicitly stored
default elements, they are counted too.

See also: (`SparseArrays.nnz`)(https://docs.julialang.org/en/v1/stdlib/SparseArrays/#SparseArrays.nnz)
and (`Base.summarysize`)(https://docs.julialang.org/en/v1/base/base/#Base.summarysize)
"""
countstored(fbr::Tensor) = countstored_level(fbr.lvl, 1)

countstored(arr::Array) = length(arr)

@staged function assemble!(lvl)
    contain(LowerJulia()) do ctx
        lvl = virtualize(ctx.code, :lvl, lvl)
        def = literal(virtual_level_default(lvl))
        lvl = declare_level!(ctx, lvl, literal(0), def)
        push!(ctx.code.preamble, assemble_level!(ctx, lvl, literal(1), literal(1)))
        lvl = freeze_level!(ctx, lvl, literal(1))
        ctx(lvl)
    end
end

Base.summary(fbr::Tensor) = "$(join(size(fbr), "×")) Tensor($(summary(fbr.lvl)))"
Base.summary(fbr::SubFiber) = "$(join(size(fbr), "×")) SubFiber($(summary(fbr.lvl)))"

Base.similar(fbr::AbstractFiber) = similar(fbr, default(fbr), eltype(fbr), size(fbr))
Base.similar(fbr::AbstractFiber, eltype::Type) = similar(fbr, convert(eltype, default(fbr)), eltype, size(fbr))
Base.similar(fbr::AbstractFiber, fill_value, eltype::Type) = similar(fbr, fill_value, eltype, size(fbr))
Base.similar(fbr::AbstractFiber, dims::Tuple) = similar(fbr, default(fbr), eltype(fbr), dims)
Base.similar(fbr::AbstractFiber, eltype::Type, dims::Tuple) = similar(fbr, convert(eltype, default(fbr)), eltype, dims)
Base.similar(fbr::AbstractFiber, fill_value, eltype::Type, dims::Tuple) = Tensor(similar_level(fbr.lvl, fill_value, eltype, dims...))

moveto(tns::Tensor, device) = Tensor(moveto(tns.lvl, device))