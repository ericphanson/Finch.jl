using Base: Broadcast
using Base.Broadcast: Broadcasted, BroadcastStyle, AbstractArrayStyle
using Base.Broadcast: combine_eltypes
using Base: broadcasted
using LinearAlgebra

struct FinchStyle{N} <: BroadcastStyle
end
Base.Broadcast.BroadcastStyle(F::Type{<:AbstractTensor}) = FinchStyle{ndims(F)}()
Base.Broadcast.broadcastable(fbr::AbstractTensor) = fbr
Base.Broadcast.BroadcastStyle(a::FinchStyle{N}, b::FinchStyle{M}) where {M, N} = FinchStyle{max(M, N)}()
Base.Broadcast.BroadcastStyle(a::LazyStyle{M}, b::FinchStyle{N}) where {M, N} = LazyStyle{max(M, N)}()
Base.Broadcast.BroadcastStyle(a::FinchStyle{N}, b::Broadcast.AbstractArrayStyle{M}) where {M, N} = FinchStyle{max(M, N)}()

function Base.materialize!(dest, bc::Broadcasted{<:FinchStyle})
    return copyto!(dest, bc)
end

function Base.materialize(bc::Broadcasted{<:FinchStyle})
    return copy(bc)
end

function Base.copyto!(out, bc::Broadcasted{FinchStyle{N}}) where {N}
    compute(copyto!(out, copy(Broadcasted{LazyStyle{N}}(bc.f, bc.args))))
end

function Base.copy(bc::Broadcasted{FinchStyle{N}}) where {N}
    return compute(copy(Broadcasted{LazyStyle{N}}(bc.f, bc.args)))
end

function Base.reduce(op, src::AbstractTensor; dims=:, init= initial_value(op, eltype(src)))
    res = compute(reduce(op, lazy(src); dims=dims, init=init))
    if dims === Colon()
        return res[]
    else
        return res
    end
end

function Base.mapreduce(f, op, src::AbstractTensor, args::Union{AbstractTensor, Base.AbstractArrayOrBroadcasted, Number}...; kw...)
    reduce(op, broadcasted(f, src, args...); kw...)
end
function Base.map(f, src::AbstractTensor, args::Union{AbstractTensor, Base.AbstractArrayOrBroadcasted, Number}...)
    f.(src, args...)
end
function Base.map!(dst, f, src::AbstractTensor, args::Union{AbstractTensor, Base.AbstractArrayOrBroadcasted}...)
    copyto!(dst, Base.broadcasted(f, src, args...))
end

function Base.reduce(op::Function, bc::Broadcasted{FinchStyle{N}}; dims=:, init = initial_value(op, combine_eltypes(bc.f, bc.args))) where {N}
    res = compute(reduce(op, copy(Broadcasted{LazyStyle{N}}(bc.f, bc.args)); dims=dims, init=init))
    if dims === Colon()
        return res[]
    else
        return res
    end
end

function tensordot(A::AbstractTensor, B::AbstractTensor, idxs; kw...)
    compute(tensordot(lazy(A), lazy(B), idxs; kw...))
end

Base.:+(
    x::AbstractTensor,
    y::Union{AbstractTensor, Base.AbstractArrayOrBroadcasted, Number},
    z::Union{AbstractTensor, Base.AbstractArrayOrBroadcasted, Number}...
) = map(+, x, y, z...)
Base.:+(
    x::Union{AbstractTensor, Base.AbstractArrayOrBroadcasted, Number},
    y::AbstractTensor,
    z::Union{AbstractTensor, Base.AbstractArrayOrBroadcasted, Number}...
) = map(+, y, x, z...)
Base.:+(
    x::AbstractTensor,
    y::AbstractTensor,
    z::Union{AbstractTensor, Base.AbstractArrayOrBroadcasted, Number}...
) = map(+, x, y, z...)
Base.:*(
    x::AbstractTensor,
    y::Number,
    z::Number...
) = map(*, x, y, z...)
Base.:*(
    x::Number,
    y::AbstractTensor,
    z::Number...
) = map(*, y, x, z...)

Base.:-(x::AbstractTensor) = map(-, x)

Base.:-(x::AbstractTensor, y::Union{AbstractTensor, Base.AbstractArrayOrBroadcasted, Number}) = map(-, x, y)
Base.:-(x::Union{AbstractTensor, Base.AbstractArrayOrBroadcasted, Number}, y::Tensor) = map(-, x, y)
Base.:-(x::AbstractTensor, y::AbstractTensor) = map(-, x, y)

Base.:/(x::AbstractTensor, y::Number) = map(/, x, y)
Base.:/(x::Number, y::AbstractTensor) = map(\, y, x)

const AbstractTensorOrBroadcast = Union{<:AbstractTensor, <:Broadcasted{FinchStyle{N}} where N}

Base.sum(arr::AbstractTensorOrBroadcast; kwargs...) = reduce(+, arr; kwargs...)
Base.prod(arr::AbstractTensorOrBroadcast; kwargs...) = reduce(*, arr; kwargs...)
Base.any(arr::AbstractTensorOrBroadcast; kwargs...) = reduce(or, arr; init = false, kwargs...)
Base.all(arr::AbstractTensorOrBroadcast; kwargs...) = reduce(and, arr; init = true, kwargs...)
Base.minimum(arr::AbstractTensorOrBroadcast; kwargs...) = reduce(min, arr; init = Inf, kwargs...)
Base.maximum(arr::AbstractTensorOrBroadcast; kwargs...) = reduce(max, arr; init = -Inf, kwargs...)

Base.extrema(arr::AbstractTensorOrBroadcast; kwargs...) = mapreduce(plex, min1max2, arr; init = (Inf, -Inf), kwargs...)

function LinearAlgebra.norm(arr::AbstractTensorOrBroadcast, p::Real = 2)
    if p == 2
        return root(sum(broadcasted(square, arr)))
    elseif p == 1
        return sum(broadcasted(abs, arr))
    elseif p == Inf
        return maximum(broadcasted(abs, arr))
    elseif p == 0
        return sum(broadcasted(!, broadcasted(iszero, arr)))
    elseif p == -Inf
        return minimum(broadcasted(abs, arr))
    else
        return root(sum(broadcasted(power, broadcasted(norm, arr, p), p)))
    end
end
