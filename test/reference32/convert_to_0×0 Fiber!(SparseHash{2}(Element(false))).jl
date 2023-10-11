begin
    tmp_lvl = (ex.bodies[1]).tns.bind.lvl
    tmp_lvl_ptr = (ex.bodies[1]).tns.bind.lvl.ptr
    tmp_lvl_tbl = (ex.bodies[1]).tns.bind.lvl.tbl
    tmp_lvl_srt = (ex.bodies[1]).tns.bind.lvl.srt
    tmp_lvl_2 = tmp_lvl.lvl
    tmp_lvl_val = tmp_lvl.lvl.val
    ref_lvl = (ex.bodies[2]).body.body.rhs.tns.bind.lvl
    ref_lvl_ptr = ref_lvl.ptr
    ref_lvl_idx = ref_lvl.idx
    ref_lvl_2 = ref_lvl.lvl
    ref_lvl_ptr_2 = ref_lvl_2.ptr
    ref_lvl_idx_2 = ref_lvl_2.idx
    ref_lvl_2_val = ref_lvl_2.lvl.val
    tmp_lvl_qos_fill = 0
    tmp_lvl_qos_stop = 0
    empty!(tmp_lvl_tbl)
    empty!(tmp_lvl_srt)
    Finch.resize_if_smaller!(tmp_lvl_ptr, 1 + 1)
    Finch.fill_range!(tmp_lvl_ptr, 0, 1 + 1, 1 + 1)
    ref_lvl_q = ref_lvl_ptr[1]
    ref_lvl_q_stop = ref_lvl_ptr[1 + 1]
    if ref_lvl_q < ref_lvl_q_stop
        ref_lvl_i1 = ref_lvl_idx[ref_lvl_q_stop - 1]
    else
        ref_lvl_i1 = 0
    end
    phase_stop = min(ref_lvl_i1, ref_lvl.shape)
    if phase_stop >= 1
        j = 1
        if ref_lvl_idx[ref_lvl_q] < 1
            ref_lvl_q = Finch.scansearch(ref_lvl_idx, 1, ref_lvl_q, ref_lvl_q_stop - 1)
        end
        while j <= phase_stop
            ref_lvl_i = ref_lvl_idx[ref_lvl_q]
            phase_stop_2 = min(phase_stop, ref_lvl_i)
            if ref_lvl_i == phase_stop_2
                ref_lvl_2_q = ref_lvl_ptr_2[ref_lvl_q]
                ref_lvl_2_q_stop = ref_lvl_ptr_2[ref_lvl_q + 1]
                if ref_lvl_2_q < ref_lvl_2_q_stop
                    ref_lvl_2_i1 = ref_lvl_idx_2[ref_lvl_2_q_stop - 1]
                else
                    ref_lvl_2_i1 = 0
                end
                phase_stop_3 = min(ref_lvl_2_i1, ref_lvl_2.shape)
                if phase_stop_3 >= 1
                    i = 1
                    if ref_lvl_idx_2[ref_lvl_2_q] < 1
                        ref_lvl_2_q = Finch.scansearch(ref_lvl_idx_2, 1, ref_lvl_2_q, ref_lvl_2_q_stop - 1)
                    end
                    while i <= phase_stop_3
                        ref_lvl_2_i = ref_lvl_idx_2[ref_lvl_2_q]
                        phase_stop_4 = min(phase_stop_3, ref_lvl_2_i)
                        if ref_lvl_2_i == phase_stop_4
                            ref_lvl_3_val = ref_lvl_2_val[ref_lvl_2_q]
                            tmp_lvl_key_2 = (1, (phase_stop_4, phase_stop_2))
                            tmp_lvl_q_2 = get(tmp_lvl_tbl, tmp_lvl_key_2, tmp_lvl_qos_fill + 1)
                            if tmp_lvl_q_2 > tmp_lvl_qos_stop
                                tmp_lvl_qos_stop = max(tmp_lvl_qos_stop << 1, 1)
                                Finch.resize_if_smaller!(tmp_lvl_val, tmp_lvl_qos_stop)
                                Finch.fill_range!(tmp_lvl_val, false, tmp_lvl_q_2, tmp_lvl_qos_stop)
                            end
                            tmp_lvl_val[tmp_lvl_q_2] = ref_lvl_3_val
                            if tmp_lvl_q_2 > tmp_lvl_qos_fill
                                tmp_lvl_qos_fill = tmp_lvl_q_2
                                tmp_lvl_tbl[tmp_lvl_key_2] = tmp_lvl_q_2
                                tmp_lvl_ptr[1 + 1] += 1
                            end
                            ref_lvl_2_q += 1
                        end
                        i = phase_stop_4 + 1
                    end
                end
                ref_lvl_q += 1
            end
            j = phase_stop_2 + 1
        end
    end
    resize!(tmp_lvl_srt, length(tmp_lvl_tbl))
    copyto!(tmp_lvl_srt, pairs(tmp_lvl_tbl))
    sort!(tmp_lvl_srt, by = hashkeycmp)
    for p = 2:1 + 1
        tmp_lvl_ptr[p] += tmp_lvl_ptr[p - 1]
    end
    resize!(tmp_lvl_ptr, 1 + 1)
    qos = tmp_lvl_ptr[end] - 1
    resize!(tmp_lvl_srt, qos)
    resize!(tmp_lvl_val, qos)
    (tmp = Fiber((SparseHashLevel){2, Tuple{Int32, Int32}}(tmp_lvl_2, (ref_lvl_2.shape, ref_lvl.shape), tmp_lvl_ptr, tmp_lvl_tbl, tmp_lvl_srt)),)
end
