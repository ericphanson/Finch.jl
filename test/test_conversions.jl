@testset "conversions" begin
    @info "Testing Tensor Conversions"
    for base in [
        #Pattern,
        Element{false},
    ]
        #=
        for arr in [
            fill(false),
            fill(true)
        ]
            ref = Scalar(false)
            res = Scalar(false)
            @finch ref[] = arr[]
            tmp = Tensor(base())
            @finch tmp[] = ref[]
            @finch res[] = tmp[]
            @test ref[] == res[]
        end
        =#

        if true #base != Pattern
            for inner in [
                () -> Dense(base()),
                () -> RepeatRLE{false}(),
                () -> SparseRLE(base()),
                () -> Dense(Separation(base())),
            ]
                for (idx, arr) in enumerate([
                    fill(false, 5),
                    fill(true, 5),
                    [false, true, true, false, false, true],
                    begin
                        x = fill(false, 1111)
                        x[2] = true 
                        x[3]= true
                        x[555:999] .= true
                        x[1001] = true
                        x
                    end,
                   ])
                    ref = Tensor(SparseList(Element(false)))
                    ref = dropdefaults!(ref, arr)
                    tmp = Tensor(inner())
                    @testset "convert $(summary(tmp)) $(idx)" begin
                        @finch (tmp .= 0; for i=_; tmp[i] = ref[i] end; return tmp)
                        check = Scalar(true)
                        @finch for i=_; check[] &= tmp[i] == ref[i] end
                        @test check[]
                    end
                end
                for outer in [
                    () -> Dense(inner()),
                    () -> SparseList(inner()),
                ]

                    for (arr_key, arr) in [
                        ("5x5_falses", fill(false, 5, 5)),
                        ("5x5_trues", fill(true, 5, 5)),
                        ("4x4_bool_mix", [false true  false true ;
                        false false false false
                        true  true  true  true
                        false true  false true ])
                    ]
                        ref = Tensor(SparseList(SparseList(Element(false))))
                        res = Tensor(SparseList(SparseList(Element(false))))
                        ref = dropdefaults!(ref, arr)
                        tmp = Tensor(outer())
                        @testset "convert $arr_key $(summary(tmp))"  begin
                            @finch (tmp .= 0; for j=_, i=_; tmp[i, j] = ref[i, j] end; return tmp)
                            check = Scalar(true)
                            @finch for j=_, i=_; check[] &= tmp[i, j] == ref[i, j] end
                            @test check[]
                        end
                    end
                end
            end
        end

        for inner in [
            () -> SparseList(base()),
            () -> SparseVBL(base()),
            () -> SparseByteMap(base()),
            () -> SparseHash{1}(base()),
            () -> SparseCOO{1}(base()),
            () -> SparseRLE(base()),
        ]
            output = false
            for arr in [
                fill(false, 5),
                fill(true, 5),
                [false, true, true, false, false, true]
            ]
                ref = Tensor(SparseList(Element(false)))
                res = Tensor(SparseList(Element(false)))
                ref = dropdefaults!(ref, arr)
                tmp = Tensor(inner())
                @testset "convert $(summary(tmp))" begin
                    if !output
                        check_output("convert_to_$(summary(tmp)).jl", @finch_code (tmp .= 0; for i=_; tmp[i] = ref[i] end; return tmp))
                        check_output("convert_from_$(summary(tmp)).jl", @finch_code (res .= 0; for i=_; res[i] = tmp[i] end; return tmp))
                        output = true
                    end
                    @finch (tmp .= 0; for i=_; tmp[i] = ref[i] end; return tmp)
                    @finch (res .= 0; for i=_; res[i] = tmp[i] end; return tmp)
                    @test Structure(ref) == Structure(res)
                end
            end

            for outer in [
                () -> Dense(inner()),
                () -> SparseList(inner()),
            ]

                output = false
                for (arr_key, arr) in [
                    ("5x5_falses", fill(false, 5, 5)),
                    ("5x5_trues", fill(true, 5, 5)),
                    ("4x4_bool_mix", [false true  false true ;
                    false false false false
                    true  true  true  true
                    false true  false true ])
                ]
                    ref = Tensor(SparseList(SparseList(Element(false))))
                    res = Tensor(SparseList(SparseList(Element(false))))
                    ref = dropdefaults!(ref, arr)
                    tmp = Tensor(outer())
                    @testset "convert $arr_key $(summary(tmp))"  begin
                        if !output
                            check_output("convert_to_$(summary(tmp)).jl", @finch_code (tmp .= 0; for j=_,i=_; tmp[i, j] = ref[i, j] end; return tmp))
                            check_output("convert_from_$(summary(tmp)).jl", @finch_code (res .= 0; for j=_,i=_; res[i, j] = tmp[i, j] end; return res))
                            output = true
                        end
                        @finch (tmp .= 0; for j=_, i=_; tmp[i, j] = ref[i, j] end; return tmp)
                        @finch (res .= 0; for j=_, i=_; res[i, j] = tmp[i, j] end; return res)
                        @test Structure(ref) == Structure(res)
                    end
                end
            end
        end

        for inner in [
            () -> SparseTriangle{1}(base()),
            () -> SparseRLE(base()),
        ]
            output = false
            for arr in [
                fill(false, 5),
                fill(true, 5),
                [false, true, true, false, false, true]
            ]
                ref = Tensor(SparseList(Element(false)))
                res = Tensor(SparseList(Element(false)))
                tmp = Tensor(inner())
                @testset "convert $(summary(tmp))" begin
                    if !output
                        check_output("convert_to_$(summary(tmp)).jl", @finch_code (tmp .= 0; for i=_; tmp[i] = ref[i] end; return tmp))
                        check_output("convert_from_$(summary(tmp)).jl", @finch_code (res .= 0; for i=_; res[i] = tmp[i] end; return res))
                        output = true
                    end
                    @finch (ref .= 0; for i=_; ref[i] = arr[i] end; return ref)
                    @finch (tmp .= 0; for i=_; tmp[i] = ref[i] end; return tmp)
                    @finch (res .= 0; for i=_; res[i] = tmp[i] end; return res)
                    @test Structure(ref) == Structure(res)
                end
            end

            for outer in [
                () -> Dense(inner()),
                () -> SparseList(inner()),
            ]
                output = false
                for (arr_key, arr) in [
                    ("5x5_falses", fill(false, 5, 5)),
                    ("5x5_trues", fill(true, 5, 5)),
                    ("4x4_bool_mix", [false true  false true ;
                    false false false false
                    true  true  true  true
                    false true  false true ])
                ]
                    ref = Tensor(SparseList(SparseList(Element(false))))
                    res = Tensor(SparseList(SparseList(Element(false))))
                    tmp = Tensor(outer())
                    @testset "convert $arr_key $(summary(tmp))"  begin
                        if !output
                            check_output("convert_to_$(summary(tmp)).jl", @finch_code (tmp .= 0; for j=_,i=_; tmp[i, j] = ref[i, j] end; return tmp))
                            check_output("convert_from_$(summary(tmp)).jl", @finch_code (res .= 0; for j=_,i=_; res[i, j] = tmp[i, j] end; return res))
                            output = true
                        end
                        @finch (ref .= 0; for j=_, i=_; ref[i, j] = arr[i, j] end; return ref)
                        @finch (tmp .= 0; for j=_, i=_; tmp[i, j] = ref[i, j] end; return tmp)
                        @finch (res .= 0; for j=_, i=_; res[i, j] = tmp[i, j] end; return res)
                        @test Structure(ref) == Structure(res)
                    end
                end
            end
        end


        for outer in [
            () -> SparseCOO{2}(base()),
            () -> SparseHash{2}(base()),
            () -> SparseRLE(SparseRLE(base())),
        ]
            output = false
            for (arr_key, arr) in [
                ("5x5_falses", fill(false, 5, 5)),
                ("5x5_trues", fill(true, 5, 5)),
                ("4x4_bool_mix", [false true  false true ;
                false false false false
                true  true  true  true
                false true  false true ])
            ]
                ref = Tensor(SparseList(SparseList(Element(false))))
                res = Tensor(SparseList(SparseList(Element(false))))
                ref = dropdefaults!(ref, arr)
                tmp = Tensor(outer())
                @testset "convert $arr_key $(summary(tmp))"  begin
                    if !output
                        check_output("convert_to_$(summary(tmp)).jl", @finch_code (tmp .= 0; for j=_,i=_; tmp[i, j] = ref[i, j] end; return tmp))
                        check_output("convert_from_$(summary(tmp)).jl", @finch_code (res .= 0; for j=_,i=_; res[i, j] = tmp[i, j] end; return res))
                        output = true
                    end
                    @finch (tmp .= 0; for j=_, i=_; tmp[i, j] = ref[i, j] end; return tmp)
                    @finch (res .= 0; for j=_, i=_; res[i, j] = tmp[i, j] end; return res)
                    @test Structure(ref) == Structure(res)
                end
            end
        end

        for outer in [
            () -> SparseTriangle{2}(base()),
            () -> SparseRLE(SparseRLE(base())),
        ]
            output = false
            for (arr_key, arr) in [
                ("5x5_falses", fill(false, 5, 5)),
                ("5x5_trues", fill(true, 5, 5)),
                ("4x4_bool_mix", [false true  false true ;
                false false false false
                true  true  true  true
                false true  false true ])
            ]
                ref = Tensor(SparseList(SparseList(Element(false))))
                res = Tensor(SparseList(SparseList(Element(false))))
                ref = dropdefaults!(ref, arr)
                tmp = Tensor(outer())
                @testset "convert $arr_key $(summary(tmp))"  begin
                    if !output
                        check_output("convert_to_$(summary(tmp)).jl", @finch_code (tmp .= 0; for j=_,i=_; tmp[i, j] = ref[i, j] end; return tmp))
                        check_output("convert_from_$(summary(tmp)).jl", @finch_code (res .= 0; for j=_,i=_; res[i, j] = tmp[i, j] end; return res))
                        output = true
                    end
                    @finch (tmp .= 0; for j=_, i=_; tmp[i, j] = ref[i, j] end; return tmp)
                    @finch (res .= 0; for j=_, i=_; res[i, j] = tmp[i, j] end; return res)
                    check = Scalar(true)
                    @finch for j=_, i=_; if j >= i check[] &= tmp[i, j] == ref[i, j] end end
                    @test check[]
                end
            end
        end
    end

    for fmt in [
        Tensor(SparseHash{2}(Element(0.0)))
        Tensor(Dense(SparseHash{1}(Element(0.0))))
        Tensor(Dense(SparseByteMap(Element(0.0))))
    ]
        arr_1 = fsprand(10, 10, 0.5)
        fmt = copyto!(fmt, arr_1)
        arr_2 = fsprand(10, 10, 0.5)
        check_output("increment_to_$(summary(fmt)).jl", @finch_code begin
            for j = _
                for i = _
                    fmt[i, j] += arr_2[i, j]
                end
            end
        end)
        @finch begin
            for j = _
                for i = _
                    fmt[i, j] += arr_2[i, j]
                end
            end
        end
        @test fmt == arr_1 .+ arr_2
    end

    for inner in [
        () -> Dense(Element{false}()),
        () -> Dense(Separation(Element{false}())),
    ]
        for outer in [
            () -> Dense(Separation(inner())),
            () -> SparseList(inner()),
            () -> SparseList(Separation(inner())),
        ]

            for (arr_key, arr) in [
                ("5x5_falses", fill(false, 5, 5)),
                ("5x5_trues", fill(true, 5, 5)),
                ("4x4_bool_mix", [false true  false true ;
                false false false false
                true  true  true  true
                false true  false true ])
            ]
                ref = Tensor(SparseList(SparseList(Element(false))))
                res = Tensor(SparseList(SparseList(Element(false))))
                ref = dropdefaults!(ref, arr)
                tmp = Tensor(outer())
                @testset "convert Separation $arr_key $(summary(tmp))"  begin
                    @finch (tmp .= 0; for j=_, i=_; tmp[i, j] = ref[i, j] end; return tmp)
                    check = Scalar(true)
                    @finch for j=_, i=_; check[] &= tmp[i, j] == ref[i, j] end
                    @test check[]
                end
            end
        end
    end
end
