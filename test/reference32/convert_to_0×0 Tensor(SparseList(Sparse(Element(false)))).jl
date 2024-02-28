begin
    tmp_lvl = (ex.bodies[1]).tns.bind.lvl
    tmp_lvl_ptr = tmp_lvl.ptr
    tmp_lvl_idx = tmp_lvl.idx
    tmp_lvl_2 = tmp_lvl.lvl
    tmp_lvl_tbl = tmp_lvl_2.tbl
    tmp_lvl_3 = tmp_lvl_2.lvl
    tmp_lvl_2_val = tmp_lvl_2.lvl.val
    ref_lvl = (ex.bodies[2]).body.body.rhs.tns.bind.lvl
    ref_lvl_ptr = ref_lvl.ptr
    ref_lvl_idx = ref_lvl.idx
    ref_lvl_2 = ref_lvl.lvl
    ref_lvl_ptr_2 = ref_lvl_2.ptr
    ref_lvl_idx_2 = ref_lvl_2.idx
    ref_lvl_2_val = ref_lvl_2.lvl.val
    tmp_lvl_qos_stop_2 = 0
    Finch.declare_table!(tmp_lvl_tbl, 0)
    tmp_lvl_qos_stop = 0
    Finch.resize_if_smaller!(tmp_lvl_ptr, 1 + 1)
    Finch.fill_range!(tmp_lvl_ptr, 0, 1 + 1, 1 + 1)
    tmp_lvl_qos = 0 + 1
    0 < 1 || throw(FinchProtocolError("SparseListLevels cannot be updated multiple times"))
    ref_lvl_q = ref_lvl_ptr[1]
    ref_lvl_q_stop = ref_lvl_ptr[1 + 1]
    if ref_lvl_q < ref_lvl_q_stop
        ref_lvl_i1 = ref_lvl_idx[ref_lvl_q_stop - 1]
    else
        ref_lvl_i1 = 0
    end
    phase_stop = min(ref_lvl_i1, ref_lvl.shape)
    if phase_stop >= 1
        if ref_lvl_idx[ref_lvl_q] < 1
            ref_lvl_q = Finch.scansearch(ref_lvl_idx, 1, ref_lvl_q, ref_lvl_q_stop - 1)
        end
        while true
            ref_lvl_i = ref_lvl_idx[ref_lvl_q]
            if ref_lvl_i < phase_stop
                if tmp_lvl_qos > tmp_lvl_qos_stop_2
                    tmp_lvl_qos_stop_2 = max(tmp_lvl_qos_stop_2 << 1, 1)
                    Finch.resize_if_smaller!(tmp_lvl_idx, tmp_lvl_qos_stop_2)
                    assemble_table!(tmp_lvl_tbl, tmp_lvl_qos, tmp_lvl_qos_stop_2)
                end
                tmp_lvldirty = false
                tmp_lvl_2_subtbl = table_register(tmp_lvl_tbl, tmp_lvl_qos)
                ref_lvl_2_q = ref_lvl_ptr_2[ref_lvl_q]
                ref_lvl_2_q_stop = ref_lvl_ptr_2[ref_lvl_q + 1]
                if ref_lvl_2_q < ref_lvl_2_q_stop
                    ref_lvl_2_i1 = ref_lvl_idx_2[ref_lvl_2_q_stop - 1]
                else
                    ref_lvl_2_i1 = 0
                end
                phase_stop_3 = min(ref_lvl_2_i1, ref_lvl_2.shape)
                if phase_stop_3 >= 1
                    if ref_lvl_idx_2[ref_lvl_2_q] < 1
                        ref_lvl_2_q = Finch.scansearch(ref_lvl_idx_2, 1, ref_lvl_2_q, ref_lvl_2_q_stop - 1)
                    end
                    while true
                        ref_lvl_2_i = ref_lvl_idx_2[ref_lvl_2_q]
                        if ref_lvl_2_i < phase_stop_3
                            ref_lvl_3_val = ref_lvl_2_val[ref_lvl_2_q]
                            tmp_lvl_2_qos = subtable_register(tmp_lvl_tbl, tmp_lvl_2_subtbl, ref_lvl_2_i)
                            if tmp_lvl_2_qos > tmp_lvl_qos_stop
                                tmp_lvl_qos_stop = max(tmp_lvl_qos_stop << 1, 1)
                                Finch.resize_if_smaller!(tmp_lvl_2_val, tmp_lvl_qos_stop)
                                Finch.fill_range!(tmp_lvl_2_val, false, tmp_lvl_2_qos, tmp_lvl_qos_stop)
                            end
                            tmp_lvl_2_val[tmp_lvl_2_qos] = ref_lvl_3_val
                            tmp_lvldirty = true
                            ref_lvl_2_q += 1
                        else
                            phase_stop_5 = min(ref_lvl_2_i, phase_stop_3)
                            if ref_lvl_2_i == phase_stop_5
                                ref_lvl_3_val = ref_lvl_2_val[ref_lvl_2_q]
                                tmp_lvl_2_qos = subtable_register(tmp_lvl_tbl, tmp_lvl_2_subtbl, phase_stop_5)
                                if tmp_lvl_2_qos > tmp_lvl_qos_stop
                                    tmp_lvl_qos_stop = max(tmp_lvl_qos_stop << 1, 1)
                                    Finch.resize_if_smaller!(tmp_lvl_2_val, tmp_lvl_qos_stop)
                                    Finch.fill_range!(tmp_lvl_2_val, false, tmp_lvl_2_qos, tmp_lvl_qos_stop)
                                end
                                tmp_lvl_2_val[tmp_lvl_2_qos] = ref_lvl_3_val
                                tmp_lvldirty = true
                                ref_lvl_2_q += 1
                            end
                            break
                        end
                    end
                end
                if tmp_lvldirty
                    tmp_lvl_idx[tmp_lvl_qos] = ref_lvl_i
                    tmp_lvl_qos += 1
                end
                ref_lvl_q += 1
            else
                phase_stop_7 = min(ref_lvl_i, phase_stop)
                if ref_lvl_i == phase_stop_7
                    if tmp_lvl_qos > tmp_lvl_qos_stop_2
                        tmp_lvl_qos_stop_2 = max(tmp_lvl_qos_stop_2 << 1, 1)
                        Finch.resize_if_smaller!(tmp_lvl_idx, tmp_lvl_qos_stop_2)
                        assemble_table!(tmp_lvl_tbl, tmp_lvl_qos, tmp_lvl_qos_stop_2)
                    end
                    tmp_lvldirty = false
                    tmp_lvl_2_subtbl_2 = table_register(tmp_lvl_tbl, tmp_lvl_qos)
                    ref_lvl_2_q = ref_lvl_ptr_2[ref_lvl_q]
                    ref_lvl_2_q_stop = ref_lvl_ptr_2[ref_lvl_q + 1]
                    if ref_lvl_2_q < ref_lvl_2_q_stop
                        ref_lvl_2_i1 = ref_lvl_idx_2[ref_lvl_2_q_stop - 1]
                    else
                        ref_lvl_2_i1 = 0
                    end
                    phase_stop_8 = min(ref_lvl_2_i1, ref_lvl_2.shape)
                    if phase_stop_8 >= 1
                        if ref_lvl_idx_2[ref_lvl_2_q] < 1
                            ref_lvl_2_q = Finch.scansearch(ref_lvl_idx_2, 1, ref_lvl_2_q, ref_lvl_2_q_stop - 1)
                        end
                        while true
                            ref_lvl_2_i = ref_lvl_idx_2[ref_lvl_2_q]
                            if ref_lvl_2_i < phase_stop_8
                                ref_lvl_3_val_2 = ref_lvl_2_val[ref_lvl_2_q]
                                tmp_lvl_2_qos_2 = subtable_register(tmp_lvl_tbl, tmp_lvl_2_subtbl_2, ref_lvl_2_i)
                                if tmp_lvl_2_qos_2 > tmp_lvl_qos_stop
                                    tmp_lvl_qos_stop = max(tmp_lvl_qos_stop << 1, 1)
                                    Finch.resize_if_smaller!(tmp_lvl_2_val, tmp_lvl_qos_stop)
                                    Finch.fill_range!(tmp_lvl_2_val, false, tmp_lvl_2_qos_2, tmp_lvl_qos_stop)
                                end
                                tmp_lvl_2_val[tmp_lvl_2_qos_2] = ref_lvl_3_val_2
                                tmp_lvldirty = true
                                ref_lvl_2_q += 1
                            else
                                phase_stop_10 = min(ref_lvl_2_i, phase_stop_8)
                                if ref_lvl_2_i == phase_stop_10
                                    ref_lvl_3_val_2 = ref_lvl_2_val[ref_lvl_2_q]
                                    tmp_lvl_2_qos_2 = subtable_register(tmp_lvl_tbl, tmp_lvl_2_subtbl_2, phase_stop_10)
                                    if tmp_lvl_2_qos_2 > tmp_lvl_qos_stop
                                        tmp_lvl_qos_stop = max(tmp_lvl_qos_stop << 1, 1)
                                        Finch.resize_if_smaller!(tmp_lvl_2_val, tmp_lvl_qos_stop)
                                        Finch.fill_range!(tmp_lvl_2_val, false, tmp_lvl_2_qos_2, tmp_lvl_qos_stop)
                                    end
                                    tmp_lvl_2_val[tmp_lvl_2_qos_2] = ref_lvl_3_val_2
                                    tmp_lvldirty = true
                                    ref_lvl_2_q += 1
                                end
                                break
                            end
                        end
                    end
                    if tmp_lvldirty
                        tmp_lvl_idx[tmp_lvl_qos] = phase_stop_7
                        tmp_lvl_qos += 1
                    end
                    ref_lvl_q += 1
                end
                break
            end
        end
    end
    tmp_lvl_ptr[1 + 1] += (tmp_lvl_qos - 0) - 1
    for p = 1:1
        tmp_lvl_ptr[p + 1] += tmp_lvl_ptr[p]
    end
    qos_stop_3 = tmp_lvl_ptr[1 + 1] - 1
    Finch.freeze_table!(tmp_lvl_tbl, qos_stop_3)
    resize!(tmp_lvl_ptr, 1 + 1)
    qos_2 = tmp_lvl_ptr[end] - 1
    resize!(tmp_lvl_idx, qos_2)
    qos_3 = Finch.trim_table!(tmp_lvl_tbl, qos_2)
    resize!(tmp_lvl_2_val, qos_3)
    (tmp = Tensor((SparseListLevel){Int32}((SparseLevel){Int32}(tmp_lvl_3, ref_lvl_2.shape, tmp_lvl_tbl), ref_lvl.shape, tmp_lvl_ptr, tmp_lvl_idx)),)
end
