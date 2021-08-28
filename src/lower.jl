#What's going on here?  We're going to create a virtual code generator for
#nested blocks A block is a contiguous group of other blocks Initially, we
#assume the blocks are aligned, but the style of the blocks tells us how to
#merge them.  When we merge split blocks or use a block loop, we need to
#truncate the blocks to realign them.  This might produce a switch-case block
#depending on what the truncated block is.  At some point, we'll reach a point
#where we can simply emit code or simplify a block merge to a no-op the
#destination block assignment is tricky. We need to iterate over the
#destination, but it's nontrivial to do increments on a sparse destination, etc.
#If the destination is e.g. a run, then we need some rules about
#how to encode spikes as two separate runs, etc.  presumably we should simplify
#the destination and source iterators until we get to the bottom (spikes, runs,
#singles), then use destination rules about how to do the storage.

#=

#Peter about three weeeks later: It's pretty clear that locate iterators are
#sorta different from coiterate iterators, and choosing one or the other should
#be a scheduling decision.
struct VirtualSparseFiber
    Ti
    ex
    name
    default
    parent_p
    child
end

function lower(lvl::VirtualSparseFiber)
    my_p = Symbol("p_", lvl.name)
    my_p′ = Symbol("p′_", lvl.name)
    my_i′ = Symbol("i′_", lvl.name)
    return PhaseIterator(
        setup = (i)->quote
            $my_p = $(ex).pos[$(lvl.parent_p)]
            $my_p′ = $(ex).pos[$(lvl.parent_p) + 1]
        end,
        phases = (
            (i)->LoopIterator(
                is_empty = :($my_p < $my_p′),
                setup = :($my_i′ = $(ex).idx[$my_p]),
                finish = :($(ex).idx[$my_p′ - 1])
                body = (i)->CaseIterator(
                    cases = (
                        (i)->Case(:($i′ == $my_i′),
                            (i)->Spike(
                                default = Literal(lvl.default),
                                value = iterator_child(lvl, my_i′, my_p)
                                cleanup = :($my_p += 1)
                            ),
                        ),
                        (i)->Case(true,
                            (i)->Run(
                                default = Literal(lvl.default),
                            ),
                        )
                    )
                    finish = my_i′
                )
            ),
            (i)->Run(
                finish = Top(),
                default = Literal(lvl.default),
            )
        ),
        finish = Top(),
    )
end

function coiterate(itrs)
    style = reduce_style(map(IteratorStyle, itrs))
    thunk = Expr(:block)
    map(arg->(thunk = block(thunk, setup(arg))), itrs))
    thunk = block(thunk, coiterate(itrs, style))
    map(arg->(thunk = block(thunk, cleanup(arg))), itrs))
end

struct SplitStyle end

abstract type Iterator end

struct PhaseIterator
    setup
    cleanup
    phases
end

PhaseIterator(;setup=nothing, cleanup=nothing, phases=())

phases(itr::PhaseIterator) = itr.phases
phases(itr) = (itr,)

IteratorStyle(itr::PhaseIterator) = PhaseStyle()

function coiterate(itrs, ::PhaseStyle)
    pipelines = map(phases, itrs)
    pipekeys = map(pipeline->1:length(pipeline), pipelines)
    maxkey = maximum(map(maximum, pipekeys))
    phases = reshape(collect(Iterators.product(pipekeys...)), :)
    sort!(phases, by=phase->map(k->count(key->key>k, phase), 1:maxkey))
    for phase in phases
        itrs′ = map(((pipeline, key))->pipeline[key], zip(pipelines, phase))
        push!(thunk.args, coiterate(itrs′))
    end
    return thunk
end

struct CaseStyle end

struct CaseIterator
    setup
    cleanup
    cases
end

IteratorStyle(itr::CaseIterator) = CaseStyle()

CaseIterator(;setup=nothing, cleanup=nothing, cases=())

cases(itr::CaseIterator) = itr.cases
cases(itr) = [(true, itr),]

IteratorStyle(::CaseIterator, ::PhaseStyle) = PhaseStyle()

function coiterate(itrs, ::CaseStyle)
    pipelines = map(cases, itrs)
    pipekeys = map(pipeline->1:length(pipeline), pipelines)
    maxkey = maximum(map(maximum, pipekeys))
    phases = reshape(collect(Iterators.product(pipekeys...)), :)
    sort!(phases, by=phase->map(k->count(key->key>k, phase), 1:maxkey))
    for phase in phases
        itrs′ = map(((pipeline, key))->pipeline[key], zip(pipelines, phase))
        #do an if else tree
        push!(thunk.args, coiterate(itrs′))
    end
    return thunk
end

cases(itr) = (itr, )

function stage_and(a, b)
    if a == true
        return b
    elseif b == true
        return a
    else
        return :($a && $b)
    end
end

stage_and() = true
stage_and(args...) = reduce(stage_and, args)

function stage_min(args...)
    args = filter(arg -> arg !== Top(), args)
    if length(args) == 0
        return Top()
    elseif length(args) == 1
        return args[]
    else
        return :(min($args...))
    end
end

struct LoopStyle end

struct LoopIterator
    setup
    cleanup
    body
end

IteratorStyle(itr::LoopIterator) = LoopStyle()

LoopIterator(;setup=nothing, cleanup=nothing, cases=())

body(itr::LoopIterator) = itr
body(itr) = itr

function coiterate(i, itrs, ::LoopStyle)
    i′ = Symbol(i, "′")
    return quote
        while $(stage_and(map(is_valid_check, itrs)...))
            $i′ = $(stage_min(map(block_end,)))
            $(next_block(i, i′, itr))
            $(coiterate(i, map(itr->truncate(itr, i′))))
            $i = $i′
        end
    end
end

function coiterate(i, itrs, ::TruncateSingleStyle)
    i′ = Symbol(i, "′")
    return quote
        if $(stage_and(map(is_valid_check, itrs)...))
            $i′ = $(stage_min(map(block_end,)))
            $(coiterate(i, map(itr->truncate(itr, i′))))
            $i = $i′
        end
    end
end

function coiterate(i, itrs, ::TerminalStyle)
    return terminal(map(simplify, itrs))
end


=#

lower(::Pass) = :()

function lower(stmt::Assign)
    lower_assign(stmt.lhs.tns, stmt.op, lower(stmt.rhs))
end

lower(ex::Call) = :($(lower(stmt.op))(map(lower, stmt.args)))

function lower(ex::Access)
    @assert isempty(ex.idxs)
    lower_access(ex.tns)
end

function lower(stmt::Loop)
    if isempty(stmt.idxs)
        return lower(stmt.body)
    elseif length(stmt.idxs) > 1
        return lower(Loop([stmt.idxs[1]], Loop(stmt.idxs[2:end], body)))
    end
    lower_loop(stmt.body, stmt.idxs[1])
end
lower_loop(body, idx) = lower_loop(body, idx, LoopStyle(idx, body))
lower_loop(body, idx, ::Missing) = lower_loop(body, idx, ForeachStyle())

#may want to specialize lowering style based on index of current forall.
LoopStyle(idx, stmt::Loop) = LoopStyle(idx, stmt.body)
LoopStyle(idx, stmt::IndexNode) = istree(stmt) ? 
    mapreduce(arg->LoopStyle(idx, arg), _loop_style, arguments(stmt)) : missing
_loop_style(a, b) = LoopStyle(a, b) === missing ? LoopStyle(b, a) : LoopStyle(a, b)
function LoopStyle(idx, stmt::Access)
    if idx in stmt.idxs
        AccessStyle(find(idx, stmt.idxs), stmt.tns)
    else
        missing
    end
end

LoopStyle(::Missing, a) = a

struct CoiterateStyle end
struct ForeachStyle end

coiterator(idx, stmt) = stmt
function coiterator(idx, stmt::Access)
    if idx == stmt.idxs[1]
        coiterator(idx, stmt.tns)
    else
        missing
    end
end

function lower_loop(stmt, idx, ::CoiterateStyle)
    lower_loop(Prewalk((stmt->coiterator(idx, stmt))(stmt), idx))
end

function lower_loop(stmt, idx, ::ForeachStyle)
    return quote
        for $idx = 1:$(10#=dimension(idx) TODO=#)
            $(lower(stmt))
        end
    end
end