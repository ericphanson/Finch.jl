begin
    res_lvl = (ex.bodies[1]).tns.bind.lvl
    res_lvl_ptr = res_lvl.ptr
    res_lvl_idx = res_lvl.idx
    res_lvl_2 = res_lvl.lvl
    res_lvl_ptr_2 = res_lvl_2.ptr
    res_lvl_idx_2 = res_lvl_2.idx
    res_lvl_3 = res_lvl_2.lvl
    res_lvl_2_val = res_lvl_2.lvl.val
    tmp_lvl = (ex.bodies[2]).body.body.rhs.tns.bind.lvl
    tmp_lvl_2 = tmp_lvl.lvl
    tmp_lvl_2_val = tmp_lvl_2.lvl.val
    res_lvl_qos_stop = 0
    res_lvl_2_qos_fill = 0
    res_lvl_2_qos_stop = 0
    res_lvl_2_prev_pos = 0
    Finch.resize_if_smaller!(res_lvl_ptr, 1 + 1)
    Finch.fill_range!(res_lvl_ptr, 0, 1 + 1, 1 + 1)
    res_lvl_qos = 0 + 1
    0 < 1 || throw(FinchProtocolError("SparseListLevels cannot be updated multiple times"))
    for j_4 = 1:tmp_lvl.shape
        if res_lvl_qos > res_lvl_qos_stop
            res_lvl_qos_stop = max(res_lvl_qos_stop << 1, 1)
            Finch.resize_if_smaller!(res_lvl_idx, res_lvl_qos_stop)
            Finch.resize_if_smaller!(res_lvl_ptr_2, res_lvl_qos_stop + 1)
            Finch.fill_range!(res_lvl_ptr_2, 0, res_lvl_qos + 1, res_lvl_qos_stop + 1)
        end
        res_lvldirty = false
        tmp_lvl_q = (1 - 1) * tmp_lvl.shape + j_4
        tmp_lvl_2_q = 1 + fld(tmp_lvl_2.shape, 1) * (tmp_lvl_q + -1)
        res_lvl_2_qos = res_lvl_2_qos_fill + 1
        res_lvl_2_prev_pos < res_lvl_qos || throw(FinchProtocolError("SparseListLevels cannot be updated multiple times"))
        phase_stop = tmp_lvl_2.shape
        if phase_stop >= 1
            for i_5 = 1:phase_stop
                if res_lvl_2_qos > res_lvl_2_qos_stop
                    res_lvl_2_qos_stop = max(res_lvl_2_qos_stop << 1, 1)
                    Finch.resize_if_smaller!(res_lvl_idx_2, res_lvl_2_qos_stop)
                    Finch.resize_if_smaller!(res_lvl_2_val, res_lvl_2_qos_stop)
                    Finch.fill_range!(res_lvl_2_val, false, res_lvl_2_qos, res_lvl_2_qos_stop)
                end
                tmp_lvl_3_val = tmp_lvl_2_val[-1 + tmp_lvl_2_q + i_5]
                res = (res_lvl_2_val[res_lvl_2_qos] = tmp_lvl_3_val)
                res_lvldirty = true
                res_lvl_idx_2[res_lvl_2_qos] = i_5
                res_lvl_2_qos += 1
                res_lvl_2_prev_pos = res_lvl_qos
            end
        end
        res_lvl_ptr_2[res_lvl_qos + 1] += (res_lvl_2_qos - res_lvl_2_qos_fill) - 1
        res_lvl_2_qos_fill = res_lvl_2_qos - 1
        if res_lvldirty
            res_lvl_idx[res_lvl_qos] = j_4
            res_lvl_qos += 1
        end
    end
    res_lvl_ptr[1 + 1] += (res_lvl_qos - 0) - 1
    resize!(res_lvl_ptr, 1 + 1)
    for p = 1:1
        res_lvl_ptr[p + 1] += res_lvl_ptr[p]
    end
    qos_stop = res_lvl_ptr[1 + 1] - 1
    resize!(res_lvl_idx, qos_stop)
    resize!(res_lvl_ptr_2, qos_stop + 1)
    for p_2 = 1:qos_stop
        res_lvl_ptr_2[p_2 + 1] += res_lvl_ptr_2[p_2]
    end
    qos_stop_2 = res_lvl_ptr_2[qos_stop + 1] - 1
    resize!(res_lvl_idx_2, qos_stop_2)
    resize!(res_lvl_2_val, qos_stop_2)
    (res = Tensor((SparseListLevel){Int64}((SparseListLevel){Int64}(res_lvl_3, tmp_lvl_2.shape, res_lvl_ptr_2, res_lvl_idx_2), tmp_lvl.shape, res_lvl_ptr, res_lvl_idx)),)
end
