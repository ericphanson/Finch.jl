quote
    res_lvl = ((ex.bodies[1]).bodies[1]).tns.bind.lvl
    res_lvl_ptr = res_lvl.ptr
    res_lvl_idx = res_lvl.idx
    res_lvl_2 = res_lvl.lvl
    res_lvl_val = res_lvl.lvl.val
    tmp_lvl = ((ex.bodies[1]).bodies[2]).body.rhs.tns.bind.lvl
    tmp_lvl_ptr = tmp_lvl.ptr
    tmp_lvl_idx = tmp_lvl.idx
    tmp_lvl_val = tmp_lvl.lvl.val
    result = nothing
    res_lvl_qos_stop = 0
    Finch.resize_if_smaller!(res_lvl_ptr, 1 + 1)
    Finch.fill_range!(res_lvl_ptr, 0, 1 + 1, 1 + 1)
    res_lvl_qos = 0 + 1
    0 < 1 || throw(FinchProtocolError("SparseListLevels cannot be updated multiple times"))
    tmp_lvl_q = tmp_lvl_ptr[1]
    tmp_lvl_q_stop = tmp_lvl_ptr[1 + 1]
    if tmp_lvl_q < tmp_lvl_q_stop
        tmp_lvl_i1 = tmp_lvl_idx[tmp_lvl_q_stop - 1]
    else
        tmp_lvl_i1 = 0
    end
    phase_stop = min(tmp_lvl_i1, tmp_lvl.shape)
    if phase_stop >= 1
        if tmp_lvl_idx[tmp_lvl_q] < 1
            tmp_lvl_q = Finch.scansearch(tmp_lvl_idx, 1, tmp_lvl_q, tmp_lvl_q_stop - 1)
        end
        while true
            tmp_lvl_i = tmp_lvl_idx[tmp_lvl_q]
            if tmp_lvl_i < phase_stop
                pointer_to_lvl_val = (tmp_lvl_val[tmp_lvl_q]).val
                pointer_to_lvl_2_val = pointer_to_lvl_val[1]
                if res_lvl_qos > res_lvl_qos_stop
                    res_lvl_qos_stop = max(res_lvl_qos_stop << 1, 1)
                    Finch.resize_if_smaller!(res_lvl_idx, res_lvl_qos_stop)
                    Finch.resize_if_smaller!(res_lvl_val, res_lvl_qos_stop)
                    Finch.fill_range!(res_lvl_val, 0.0, res_lvl_qos, res_lvl_qos_stop)
                end
                res = (res_lvl_val[res_lvl_qos] = pointer_to_lvl_2_val)
                res_lvl_idx[res_lvl_qos] = tmp_lvl_i
                res_lvl_qos += 1
                tmp_lvl_q += 1
            else
                phase_stop_3 = min(tmp_lvl_i, phase_stop)
                if tmp_lvl_i == phase_stop_3
                    pointer_to_lvl_val_2 = (tmp_lvl_val[tmp_lvl_q]).val
                    pointer_to_lvl_3_val = pointer_to_lvl_val_2[1]
                    if res_lvl_qos > res_lvl_qos_stop
                        res_lvl_qos_stop = max(res_lvl_qos_stop << 1, 1)
                        Finch.resize_if_smaller!(res_lvl_idx, res_lvl_qos_stop)
                        Finch.resize_if_smaller!(res_lvl_val, res_lvl_qos_stop)
                        Finch.fill_range!(res_lvl_val, 0.0, res_lvl_qos, res_lvl_qos_stop)
                    end
                    res_lvl_val[res_lvl_qos] = pointer_to_lvl_3_val
                    res_lvl_idx[res_lvl_qos] = phase_stop_3
                    res_lvl_qos += 1
                    tmp_lvl_q += 1
                end
                break
            end
        end
    end
    res_lvl_ptr[1 + 1] += (res_lvl_qos - 0) - 1
    resize!(res_lvl_ptr, 1 + 1)
    for p = 1:1
        res_lvl_ptr[p + 1] += res_lvl_ptr[p]
    end
    qos_stop = res_lvl_ptr[1 + 1] - 1
    resize!(res_lvl_idx, qos_stop)
    resize!(res_lvl_val, qos_stop)
    result = (res = Tensor((SparseListLevel){Int32}(res_lvl_2, tmp_lvl.shape, res_lvl_ptr, res_lvl_idx)),)
    result
end
