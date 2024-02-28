"""
    SeparateLevel{Lvl, [Val]}()

A subfiber of a Separate level is a separate tensor of type `Lvl`, in it's
own memory space.

Each sublevel is stored in a vector of type `Val` with `eltype(Val) = Lvl`.

```jldoctest
julia> Tensor(Dense(Separate(Element(0.0))), [1, 2, 3])
Dense [1:3]
├─ [1]: Pointer ->
│  └─ 1.0
├─ [2]: Pointer ->
│  └─ 2.0
└─ [3]: Pointer ->
   └─ 3.0
```
"""
struct SeparateLevel{Lvl, Val} <: AbstractLevel
    lvl::Lvl
    val::Val
end
const Separate = SeparateLevel

SeparateLevel(lvl::Lvl) where {Lvl} = SeparateLevel(lvl, [lvl])
SeparateLevel{Lvl, Val}(lvl::Lvl) where {Lvl, Val} =  SeparateLevel{Lvl, Val}(lvl, [lvl])
Base.summary(::Separate{Lvl, Val}) where {Lvl, Val} = "Separate($(Lvl))"

similar_level(lvl::Separate{Lvl, Val}) where {Lvl, Val} = SeparateLevel{Lvl, Val}(similar_level(lvl.lvl))

postype(::Type{<:Separate{Lvl, Val}}) where {Lvl, Val} = postype(Lvl)

function moveto(lvl::SeparateLevel, device)
    lvl_2 = moveto(lvl.lvl, device)
    val_2 = moveto(lvl.val, device)
    return SeparateLevel(lvl_2, val_2)
end

pattern!(lvl::SeparateLevel) = SeparateLevel(pattern!(lvl.lvl), map(pattern!, lvl.val))
redefault!(lvl::SeparateLevel, init) = SeparateLevel(redefault!(lvl.lvl, init), map(lvl_2->redefault!(lvl_2, init), lvl.val))
Base.resize!(lvl::SeparateLevel, dims...) = SeparateLevel(resize!(lvl.lvl, dims...), map(lvl_2->resize!(lvl_2, dims...), lvl.val))


function Base.show(io::IO, lvl::SeparateLevel{Lvl, Val}) where {Lvl, Val}
    print(io, "Separate(")
    if get(io, :compact, false)
        print(io, "…")
    else
        show(IOContext(io, :typeinfo=>Val), lvl.val)
        print(io, ", ")
        show(IOContext(io, :typeinfo=>Val), lvl.lvl)
    end
    print(io, ")")
end

labelled_show(io::IO, ::SubFiber{<:SeparateLevel}) =
    print(io, "Pointer -> ")

function labelled_children(fbr::SubFiber{<:SeparateLevel})
    lvl = fbr.lvl
    pos = fbr.pos
    pos > length(lvl.val) && return []
    [LabelledTree(SubFiber(lvl.val[pos], 1))]
end

@inline level_ndims(::Type{<:SeparateLevel{Lvl, Val}}) where {Lvl, Val} = level_ndims(Lvl)
@inline level_size(lvl::SeparateLevel{Lvl, Val}) where {Lvl, Val} = level_size(lvl.lvl)
@inline level_axes(lvl::SeparateLevel{Lvl, Val}) where {Lvl, Val} = level_axes(lvl.lvl)
@inline level_eltype(::Type{SeparateLevel{Lvl, Val}}) where {Lvl, Val} = level_eltype(Lvl)
@inline level_default(::Type{<:SeparateLevel{Lvl, Val}}) where {Lvl, Val} = level_default(Lvl)

(fbr::Tensor{<:SeparateLevel})() = SubFiber(fbr.lvl, 1)()
(fbr::SubFiber{<:SeparateLevel})() = fbr #TODO this is not consistent somehow
function (fbr::SubFiber{<:SeparateLevel})(idxs...)
    q = fbr.pos
    return Tensor(fbr.lvl.val[q])(idxs...)
end

countstored_level(lvl::SeparateLevel, pos) = pos

mutable struct VirtualSeparateLevel <: AbstractVirtualLevel
    lvl  # stand in for the sublevel for virutal resize, etc.
    ex
    Tv
    Lvl
    Val
end

postype(lvl:: VirtualSeparateLevel) = postype(lvl.lvl)

is_level_injective(::VirtualSeparateLevel, ctx) = [is_level_injective(lvl.lvl, ctx)..., true]
is_level_concurrent(::VirtualSeparateLevel, ctx) = [is_level_concurrent(lvl.lvl, ctx)..., true]
is_level_atomic(lvl::VirtualSeparateLevel, ctx) = is_level_atomic(lvl.lvl, ctx)

function lower(lvl::VirtualSeparateLevel, ctx::AbstractCompiler, ::DefaultStyle)
    quote
        $SeparateLevel{$(lvl.Lvl), $(lvl.Val)}($(ctx(lvl.lvl)), $(lvl.ex).val)
    end
end

function virtualize(ex, ::Type{SeparateLevel{Lvl, Val}}, ctx, tag=:lvl) where {Lvl, Val}
    sym = freshen(ctx, tag)
    push!(ctx.preamble, quote
        $sym = $ex
    end)
    lvl_2 = virtualize(:($ex.lvl), Lvl, ctx, sym)
    VirtualSeparateLevel(lvl_2, sym, typeof(level_default(Lvl)), Lvl, Val)
end

Base.summary(lvl::VirtualSeparateLevel) = "Separate($(lvl.Lvl))"

virtual_level_resize!(lvl::VirtualSeparateLevel, ctx, dims...) = (lvl.lvl = virtual_level_resize!(lvl.lvl, ctx, dims...); lvl)
virtual_level_size(lvl::VirtualSeparateLevel, ctx) = virtual_level_size(lvl.lvl, ctx)
virtual_level_eltype(lvl::VirtualSeparateLevel) = virtual_level_eltype(lvl.lvl)
virtual_level_default(lvl::VirtualSeparateLevel) = virtual_level_default(lvl.lvl)

function declare_level!(lvl::VirtualSeparateLevel, ctx, pos, init)
    #declare_level!(lvl.lvl, ctx_2, literal(1), init)
    return lvl
end

function assemble_level!(lvl::VirtualSeparateLevel, ctx, pos_start, pos_stop)
    pos_start = cache!(ctx, :pos_start, simplify(pos_start, ctx))
    pos_stop = cache!(ctx, :pos_stop, simplify(pos_stop, ctx))
    idx = freshen(ctx.code, :idx)
    sym = freshen(ctx.code, :pointer_to_lvl)
    push!(ctx.code.preamble, quote
        Finch.resize_if_smaller!($(lvl.ex).val, $(ctx(pos_stop)))
        for $idx in $(ctx(pos_start)):$(ctx(pos_stop))
            $sym = similar_level($(lvl.ex).lvl)
            $(contain(ctx) do ctx_2
                lvl_2 = virtualize(sym, lvl.Lvl, ctx_2.code, sym)
                lvl_2 = declare_level!(lvl_2, ctx_2, literal(0), literal(virtual_level_default(lvl_2)))
                lvl_2 = virtual_level_resize!(lvl_2, ctx_2, virtual_level_size(lvl.lvl, ctx_2)...)
                push!(ctx_2.code.preamble, assemble_level!(lvl_2, ctx_2, literal(1), literal(1)))
                lvl_2 = freeze_level!(lvl_2, ctx_2, literal(1))
                :($(lvl.ex).val[$idx] = $(ctx_2(lvl_2)))
            end)
        end
    end)
    lvl
end

supports_reassembly(::VirtualSeparateLevel) = true
function reassemble_level!(lvl::VirtualSeparateLevel, ctx, pos_start, pos_stop)
    pos_start = cache!(ctx, :pos_start, simplify(pos_start, ctx))
    pos_stop = cache!(ctx, :pos_stop, simplify(pos_stop, ctx))
    idx = freshen(ctx.code, :idx)
    push!(ctx.code.preamble, quote
        for $idx in $(ctx(pos_start)):$(ctx(pos_stop))
            $(contain(ctx) do ctx_2
                lvl_2 = virtualize(:($(lvl.ex).val[$idx]), lvl.Lvl, ctx_2.code, sym)
                declare_level!(lvl_2, ctx_2, literal(1), init)
                push!(ctx_2.code.preamble, assemble_level!(lvl_2, ctx, literal(1), literal(1)))
                lvl_2 = freeze_level!(lvl_2, ctx, literal(1))
                :($(lvl.ex).val[$idx] = $(ctx_2(lvl_2)))
            end)
        end
    end)
    lvl
end

function freeze_level!(lvl::VirtualSeparateLevel, ctx, pos)
    return lvl
end

function thaw_level!(lvl::VirtualSeparateLevel, ctx::AbstractCompiler, pos)
    return lvl
end

function trim_level!(lvl::VirtualSeparateLevel, ctx::AbstractCompiler, pos)
    idx = freshen(ctx.code, :idx)
    sym = freshen(ctx.code, :pointer_to_lvl)

    push!(ctx.code.preamble, quote
        for $idx in 1:$(ctx(pos))
            $(contain(ctx) do ctx_2
                lvl_2 = virtualize(:($(lvl.ex).val[$idx]), lvl.Lvl, ctx_2.code, sym)
                trim_level!(lvl_2, ctx_2, literal(1))
            end)
        end
    end)
    lvl
end

function instantiate(fbr::VirtualSubFiber{VirtualSeparateLevel}, ctx, mode::Reader, protos)
    (lvl, pos) = (fbr.lvl, fbr.pos)
    tag = lvl.ex
    isnulltest = freshen(ctx.code, tag, :_nulltest)
    D = level_default(lvl.Lvl)
    sym = freshen(ctx.code, :pointer_to_lvl)
    val = freshen(ctx.code, lvl.ex, :_val)
    return body = Thunk(
        body = (ctx) -> begin
            lvl_2 = virtualize(:($(lvl.ex).val[$(ctx(pos))]), lvl.Lvl, ctx.code, sym)
            instantiate(VirtualSubFiber(lvl_2, literal(1)), ctx, mode, protos)
        end,
    )
end

function instantiate(fbr::VirtualSubFiber{VirtualSeparateLevel}, ctx, mode::Updater, protos)
    (lvl, pos) = (fbr.lvl, fbr.pos)
    tag = lvl.ex
    sym = freshen(ctx.code, :pointer_to_lvl)

    return body = Thunk(
        body = (ctx) -> begin
            lvl_2 = virtualize(:($(lvl.ex).val[$(ctx(pos))]), lvl.Lvl, ctx.code, sym)
            thaw_level!(lvl_2, ctx, literal(1))
            push!(ctx.code.preamble, assemble_level!(lvl_2, ctx, literal(1), literal(1)))
            res = instantiate(VirtualSubFiber(lvl_2, literal(1)), ctx, mode, protos)
            freeze_level!(lvl, ctx, literal(1))
            res
        end
    )
end
function instantiate(fbr::VirtualHollowSubFiber{VirtualSeparateLevel}, ctx, mode::Updater, protos)
    (lvl, pos) = (fbr.lvl, fbr.pos)
    tag = lvl.ex
    sym = freshen(ctx.code, :pointer_to_lvl)

    return body = Thunk(
        body = (ctx) -> begin
            lvl_2 = virtualize(:($(lvl.ex).val[$(ctx(pos))]), lvl.Lvl, ctx.code, sym)
            thaw_level!(lvl_2, ctx, literal(1))
            push!(ctx.code.preamble, assemble_level!(lvl_2, ctx, literal(1), literal(1)))
            res = instantiate(VirtualHollowSubFiber(lvl_2, literal(1), fbr.dirty), ctx, mode, protos)
            freeze_level!(lvl, ctx, literal(1))
            res
        end
    )
end
