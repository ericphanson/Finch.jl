begin
    tmp_lvl = (ex.bodies[1]).tns.bind.lvl
    tmp_lvl_tbl = tmp_lvl.tbl
    tmp_lvl_2 = tmp_lvl.lvl
    tmp_lvl_val = tmp_lvl.lvl.val
    ref_lvl = (ex.bodies[2]).body.rhs.tns.bind.lvl
    ref_lvl_ptr = ref_lvl.ptr
    ref_lvl_idx = ref_lvl.idx
    ref_lvl_val = ref_lvl.lvl.val
    Finch.declare_table!(tmp_lvl_tbl, 1)
    tmp_lvl_qos_stop = 0
    assemble_table!(tmp_lvl_tbl, 1, 1)
    tmp_lvl_subtbl = table_register(tmp_lvl_tbl, 1)
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
                ref_lvl_2_val = ref_lvl_val[ref_lvl_q]
                tmp_lvl_qos = subtable_register(tmp_lvl_tbl, tmp_lvl_subtbl, ref_lvl_i)
                if tmp_lvl_qos > tmp_lvl_qos_stop
                    tmp_lvl_qos_stop = max(tmp_lvl_qos_stop << 1, 1)
                    Finch.resize_if_smaller!(tmp_lvl_val, tmp_lvl_qos_stop)
                    Finch.fill_range!(tmp_lvl_val, false, tmp_lvl_qos, tmp_lvl_qos_stop)
                end
                tmp_lvl_val[tmp_lvl_qos] = ref_lvl_2_val
                ref_lvl_q += 1
            else
                phase_stop_3 = min(ref_lvl_i, phase_stop)
                if ref_lvl_i == phase_stop_3
                    ref_lvl_2_val = ref_lvl_val[ref_lvl_q]
                    tmp_lvl_qos = subtable_register(tmp_lvl_tbl, tmp_lvl_subtbl, phase_stop_3)
                    if tmp_lvl_qos > tmp_lvl_qos_stop
                        tmp_lvl_qos_stop = max(tmp_lvl_qos_stop << 1, 1)
                        Finch.resize_if_smaller!(tmp_lvl_val, tmp_lvl_qos_stop)
                        Finch.fill_range!(tmp_lvl_val, false, tmp_lvl_qos, tmp_lvl_qos_stop)
                    end
                    tmp_lvl_val[tmp_lvl_qos] = ref_lvl_2_val
                    ref_lvl_q += 1
                end
                break
            end
        end
    end
    qos_stop_2 = Finch.freeze_table!(tmp_lvl_tbl, 1)
    resize!(tmp_lvl_val, qos_stop_2)
    (tmp = Tensor((SparseLevel){Int32}(tmp_lvl_2, ref_lvl.shape, tmp_lvl_tbl)),)
end
