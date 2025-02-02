struct DiagMask <: AbstractTensor end

"""
    diagmask

A mask for a diagonal tensor, `diagmask[i, j] = i == j`. Note that this
specializes each column for the cases where `i < j`, `i == j`, and `i > j`.
"""
const diagmask = DiagMask()

Base.show(io::IO, ex::DiagMask) = Base.show(io, MIME"text/plain"(), ex)
function Base.show(io::IO, mime::MIME"text/plain", ex::DiagMask)
    print(io, "diagmask")
end

struct VirtualDiagMask <: AbstractVirtualTensor end

virtualize(ctx, ex, ::Type{DiagMask}) = VirtualDiagMask()
FinchNotation.finch_leaf(x::VirtualDiagMask) = virtual(x)
Finch.virtual_size(ctx, ::VirtualDiagMask) = (dimless, dimless)

function instantiate(ctx, arr::VirtualDiagMask, mode::Reader, subprotos, ::typeof(defaultread), ::typeof(defaultread))
    Unfurled(
        arr = arr,
        body = Furlable(
            body = (ctx, ext) -> Lookup(
                body = (ctx, i) -> Furlable(
                    body = (ctx, ext) -> Sequence([
                        Phase(
                            stop = (ctx, ext) -> value(:($(ctx(i)) - 1)),
                            body = (ctx, ext) -> Run(body=Fill(false))
                        ),
                        Phase(
                            stop = (ctx, ext) -> i,
                            body = (ctx, ext) -> Run(body=Fill(true)),
                        ),
                        Phase(body = (ctx, ext) -> Run(body=Fill(false)))
                    ])
                )
            )
        )
    )
end

struct UpTriMask <: AbstractTensor end

"""
    uptrimask

A mask for an upper triangular tensor, `uptrimask[i, j] = i <= j`. Note that this
specializes each column for the cases where `i <= j` and `i > j`.
"""
const uptrimask = UpTriMask()

Base.show(io::IO, ex::UpTriMask) = Base.show(io, MIME"text/plain"(), ex)
function Base.show(io::IO, mime::MIME"text/plain", ex::UpTriMask)
    print(io, "uptrimask")
end

struct VirtualUpTriMask <: AbstractVirtualTensor end

virtualize(ctx, ex, ::Type{UpTriMask}) = VirtualUpTriMask()
FinchNotation.finch_leaf(x::VirtualUpTriMask) = virtual(x)
Finch.virtual_size(ctx, ::VirtualUpTriMask) = (dimless, dimless)

function instantiate(ctx, arr::VirtualUpTriMask, mode::Reader, subprotos, ::typeof(defaultread), ::typeof(defaultread))
    Unfurled(
        arr = arr,
        body = Furlable(
            body = (ctx, ext) -> Lookup(
                body = (ctx, i) -> Furlable(
                    body = (ctx, ext) -> Sequence([
                        Phase(
                            stop = (ctx, ext) -> value(:($(ctx(i)))),
                            body = (ctx, ext) -> Run(body=Fill(true))
                        ),
                        Phase(
                            body = (ctx, ext) -> Run(body=Fill(false)),
                        )
                    ])
                )
            )
        )
    )
end

struct LoTriMask <: AbstractTensor end

"""
    lotrimask

A mask for an upper triangular tensor, `lotrimask[i, j] = i >= j`. Note that this
specializes each column for the cases where `i < j` and `i >= j`.
"""
const lotrimask = LoTriMask()

Base.show(io::IO, ex::LoTriMask) = Base.show(io, MIME"text/plain"(), ex)
function Base.show(io::IO, mime::MIME"text/plain", ex::LoTriMask)
    print(io, "lotrimask")
end

struct VirtualLoTriMask <: AbstractVirtualTensor end

virtualize(ctx, ex, ::Type{LoTriMask}) = VirtualLoTriMask()
FinchNotation.finch_leaf(x::VirtualLoTriMask) = virtual(x)
Finch.virtual_size(ctx, ::VirtualLoTriMask) = (dimless, dimless)

function instantiate(ctx, arr::VirtualLoTriMask, mode::Reader, subprotos, ::typeof(defaultread), ::typeof(defaultread))
    Unfurled(
        arr = arr,
        body = Furlable(
            body = (ctx, ext) -> Lookup(
                body = (ctx, i) -> Furlable(
                    body = (ctx, ext) -> Sequence([
                        Phase(
                            stop = (ctx, ext) -> value(:($(ctx(i)) - 1)),
                            body = (ctx, ext) -> Run(body=Fill(false))
                        ),
                        Phase(
                            body = (ctx, ext) -> Run(body=Fill(true)),
                        )
                    ])
                )
            )
        )
    )
end

struct BandMask <: AbstractTensor end

"""
    bandmask

A mask for a banded tensor, `bandmask[i, j, k] = j <= i <= k`. Note that this
specializes each column for the cases where `i < j`, `j <= i <= k`, and `k < i`.
"""
const bandmask = BandMask()

Base.show(io::IO, ex::BandMask) = Base.show(io, MIME"text/plain"(), ex)
function Base.show(io::IO, mime::MIME"text/plain", ex::BandMask)
    print(io, "bandmask")
end

struct VirtualBandMask <: AbstractVirtualTensor end

virtualize(ctx, ex, ::Type{BandMask}) = VirtualBandMask()
FinchNotation.finch_leaf(x::VirtualBandMask) = virtual(x)
Finch.virtual_size(ctx, ::VirtualBandMask) = (dimless, dimless, dimless)

function instantiate(ctx, arr::VirtualBandMask, mode, subprotos, ::typeof(defaultread), ::typeof(defaultread), ::typeof(defaultread))
    Unfurled(
        arr = arr,
        tns = Furlable(
            body = (ctx, ext) -> Lookup(
                body = (ctx, k) -> Furlable(
                    body = (ctx, ext) -> Lookup(
                        body = (ctx, j) -> Furlable(
                            body = (ctx, ext) -> Sequence([
                                Phase(
                                    stop = (ctx, ext) -> value(:($(ctx(j)) - 1)),
                                    body = (ctx, ext) -> Run(body=Fill(false))
                                ),
                                Phase(
                                    stop = (ctx, ext) -> k,
                                    body = (ctx, ext) -> Run(body=Fill(true))
                                ),
                                Phase(
                                    body = (ctx, ext) -> Run(body=Fill(false)),
                                )
                            ])
                        )
                    )
                )
            )
        )
    )
end

struct SplitMask <: AbstractTensor
    P::Int
end

Base.show(io::IO, ex::SplitMask) = Base.show(io, MIME"text/plain"(), ex)
function Base.show(io::IO, mime::MIME"text/plain", ex::SplitMask)
    print(io, "splitmask(", ex.P, ")")
end

struct VirtualSplitMask
    P
end

function virtualize(ctx, ex, ::Type{SplitMask})
    return VirtualSplitMask(value(:($ex.P), Int))
end

FinchNotation.finch_leaf(x::VirtualSplitMask) = virtual(x)
Finch.virtual_size(ctx, arr::VirtualSplitMask) = (dimless, Extent(literal(1), arr.P))

function instantiate(ctx, arr::VirtualSplitMask, mode::Reader, subprotos, ::typeof(defaultread), ::typeof(defaultread))
    Unfurled(
        arr = arr,
        body = Furlable(
            body = (ctx, ext) -> Lookup(
                body = (ctx, i) -> Furlable(
                    body = (ctx, ext_2) -> begin
                        Sequence([
                            Phase(
                                stop = (ctx, ext) -> call(+, call(-, getstart(ext_2), 1), call(fld, call(*, measure(ext_2), call(-, i, 1)), arr.P)),
                                body = (ctx, ext) -> Run(body=Fill(false))
                            ),
                            Phase(
                                stop = (ctx, ext) -> call(+, call(-, getstart(ext_2), 1), call(fld, call(*, measure(ext_2), i), arr.P)),
                                body = (ctx, ext) -> Run(body=Fill(true)),
                            ),
                            Phase(body = (ctx, ext) -> Run(body=Fill(false)))
                        ])
                    end
                )
            )
        )
    )
end

struct ChunkMask{Dim} <: AbstractTensor
    b::Int
    dim::Dim
end

Base.show(io::IO, ex::ChunkMask) = Base.show(io, MIME"text/plain"(), ex)
function Base.show(io::IO, mime::MIME"text/plain", ex::ChunkMask)
    print(io, "chunkmask(", ex.b, ex.dim, ")")
end

struct VirtualChunkMask
    b
    dim
end

function virtualize(ctx, ex, ::Type{ChunkMask{Dim}}) where {Dim}
    return VirtualChunkMask(
        value(:($ex.b), Int),
        virtualize(ctx, :($ex.dim), Dim))
end

"""
    chunkmask(b)

A mask for a chunked tensor, `chunkmask[i, j] = b * (j - 1) < i <= b * j`. Note
that this specializes each column for the cases where `i < b * (j - 1)`, `b * (j
- 1) < i <= b * j`, and `b * j < i`.
"""
function chunkmask end

function Finch.virtual_call(ctx, ::typeof(chunkmask), b, dim)
    if dim.kind === virtual
        return VirtualChunkMask(b, dim.val)
    end
end

FinchNotation.finch_leaf(x::VirtualChunkMask) = virtual(x)
Finch.virtual_size(ctx, arr::VirtualChunkMask) = (arr.dim, Extent(literal(1), call(cld, measure(arr.dim), arr.b)))

function instantiate(ctx, arr::VirtualChunkMask, mode::Reader, subprotos, ::typeof(defaultread), ::typeof(defaultread))
    Unfurled(
        arr = arr,
        body = Furlable(
            body = (ctx, ext) -> Sequence([
                Phase(
                    stop = (ctx, ext) -> call(cld, measure(arr.dim), arr.b),
                    body = (ctx, ext) -> Lookup(
                        body = (ctx, i) -> Furlable(
                            body = (ctx, ext) -> Sequence([
                                Phase(
                                    stop = (ctx, ext) -> call(*, arr.b, call(-, i, 1)),
                                    body = (ctx, ext) -> Run(body=Fill(false))
                                ),
                                Phase(
                                    stop = (ctx, ext) -> call(*, arr.b, i),
                                    body = (ctx, ext) -> Run(body=Fill(true)),
                                ),
                                Phase(body = (ctx, ext) -> Run(body=Fill(false)))
                            ])
                        )
                    )
                ),
                Phase(
                    body = (ctx, ext) -> Run(
                        body = Furlable(
                            body = (ctx, ext) -> Sequence([
                                Phase(
                                    stop = (ctx, ext) -> call(*, call(fld, measure(arr.dim), arr.b), arr.b),
                                    body = (ctx, ext) -> Run(body=Fill(false))
                                ),
                                Phase(
                                    body = (ctx, ext) -> Run(body=Fill(true)),
                                )
                            ])
                        )
                    )
                )
            ])
        )
    )
end