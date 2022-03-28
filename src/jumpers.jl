struct JumperStyle end

@kwdef struct Jumper
    body
    seek = (ctx, start) -> error("seek not implemented error")
    status = gensym()
end

isliteral(::Jumper) = false

function make_style(root::Loop, ctx::LowerJulia, node::Jumper)
    if node.status in keys(ctx.state)
        JumperStyle()
    else
        ThunkStyle()
    end
end
combine_style(a::DefaultStyle, b::JumperStyle) = JumperStyle()
combine_style(a::JumperStyle, b::JumperStyle) = JumperStyle()
combine_style(a::JumperStyle, b::RunStyle) = RunStyle()
combine_style(a::JumperStyle, b::AcceptRunStyle) = JumperStyle()
combine_style(a::JumperStyle, b::AcceptSpikeStyle) = JumperStyle()
combine_style(a::JumperStyle, b::SpikeStyle) = SpikeStyle()
combine_style(a::JumperStyle, b::CaseStyle) = CaseStyle()
combine_style(a::ThunkStyle, b::JumperStyle) = ThunkStyle()
combine_style(a::StepperStyle, b::JumperStyle) = JumperStyle()

function (ctx::LowerJulia)(root::Loop, ::JumperStyle)
    i = getname(root.idxs[1])
    i0 = ctx.freshen(i, :_start)
    push!(ctx.preamble, quote
        $i0 = $(ctx(start(ctx.dims[i])))
    end)

    if extent(ctx.dims[i]) == 1
        body = JumperVisitor(i0, ctx)(root)
        return contain(ctx) do ctx_2
            body_2 = ThunkVisitor(ctx_2)(body)
            step = ctx_2(start(ctx.dims[i]))
            body_3 = (PhaseBodyVisitor(ctx_2, i, i0, step))(body_2)
            (ctx_2)(body_3)
        end
    else
        body = JumperVisitor(i0, ctx)(root)
        guard = nothing
        body_2 = fixpoint(ctx) do ctx_2
            scope(ctx_2) do ctx_3
                body_3 = ThunkVisitor(ctx_3)(body)
                strides = (PhaseStrideVisitor(ctx_3, i, i0))(body_3)
                if length(strides) <= 1
                    step = ctx_3(stop(ctx.dims[i]))
                    body_4 = (PhaseBodyVisitor(ctx_3, i, i0, step))(body_3)
                    quote
                        $(contain(ctx_3) do ctx_4
                            restrict(ctx_4, i => Extent(Virtual{Any}(i0), Virtual{Any}(step))) do
                                (ctx_4)(body_4)
                            end
                        end)
                    end
                else
                    step = ctx.freshen(i, :_step)
                    body_4 = (PhaseBodyVisitor(ctx_3, i, i0, step))(body_3)
                    guard = :($i0 <= $(ctx_3(stop(ctx.dims[i]))))
                    quote
                        $step = min(max($(map(ctx_3, strides)...)), $(ctx_3(stop(ctx.dims[i]))))
                        $(contain(ctx_3) do ctx_4
                            restrict(ctx_4, i => Extent(Virtual{Any}(i0), Virtual{Any}(step))) do
                                (ctx_4)(body_4)
                            end
                        end)
                        $i0 = $step + 1
                    end
                end
            end
        end
        if guard !== nothing
            return quote
                while $guard
                    $body_2
                end
            end
        else
            return body_2
        end
    end
end

@kwdef struct JumperVisitor <: AbstractTransformVisitor
    start
    ctx
end
function (ctx::JumperVisitor)(node::Jumper, ::DefaultStyle)
    if false in get(ctx.ctx.state, node.status, Set())
        push!(ctx.ctx.preamble, node.seek(ctx, ctx.start))
    end
    define!(ctx.ctx, node.status, Set((:seen,)))
    node.body
end

function (ctx::SkipVisitor)(node::Jumper, ::DefaultStyle)
    define!(ctx.ctx, node.status, Set((:skipped,)))
    node
end

function (ctx::ThunkVisitor)(node::Jumper, ::DefaultStyle)
    if !haskey(ctx.ctx.state, node.status)
        define!(ctx.ctx, node.status, Set((:seen,)))
    end
    node
end