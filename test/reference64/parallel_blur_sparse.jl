begin
    output_lvl = (ex.bodies[1]).tns.bind.lvl
    output_lvl_2 = output_lvl.lvl
    output_lvl_3 = output_lvl_2.lvl
    output_lvl_2_val = output_lvl_2.lvl.val
    cpu = ((ex.bodies[2]).ext.args[2]).bind
    tmp_lvl = ((ex.bodies[2]).body.bodies[1]).tns.bind.lvl
    tmp_lvl_val = tmp_lvl.lvl.val
    input_lvl = (((ex.bodies[2]).body.bodies[2]).body.rhs.args[1]).tns.bind.lvl
    input_lvl_2 = input_lvl.lvl
    input_lvl_ptr = input_lvl_2.ptr
    input_lvl_idx = input_lvl_2.idx
    input_lvl_2_val = input_lvl_2.lvl.val
    1 == 1 + --1 || throw(DimensionMismatch("mismatched dimension limits ($(1) != $(1 + --1))"))
    input_lvl_2.shape == input_lvl_2.shape + --1 || throw(DimensionMismatch("mismatched dimension limits ($(input_lvl_2.shape) != $(input_lvl_2.shape + --1))"))
    input_lvl.shape + -0 == input_lvl.shape || throw(DimensionMismatch("mismatched dimension limits ($(input_lvl.shape + -0) != $(input_lvl.shape))"))
    1 == 1 + -0 || throw(DimensionMismatch("mismatched dimension limits ($(1) != $(1 + -0))"))
    1 == 1 + -1 || throw(DimensionMismatch("mismatched dimension limits ($(1) != $(1 + -1))"))
    input_lvl_2.shape == input_lvl_2.shape + -1 || throw(DimensionMismatch("mismatched dimension limits ($(input_lvl_2.shape) != $(input_lvl_2.shape + -1))"))
    1 == 1 + -0 || throw(DimensionMismatch("mismatched dimension limits ($(1) != $(1 + -0))"))
    y_stop = input_lvl.shape
    pos_stop = input_lvl_2.shape * input_lvl.shape
    Finch.resize_if_smaller!(output_lvl_2_val, pos_stop)
    Finch.fill_range!(output_lvl_2_val, 0.0, 1, pos_stop)
    input_lvl_ptr = moveto(input_lvl_ptr, cpu)
    input_lvl_idx = moveto(input_lvl_idx, cpu)
    input_lvl_2_val = moveto(input_lvl_2_val, cpu)
    val_2 = output_lvl_2_val
    output_lvl_2_val = moveto(output_lvl_2_val, cpu)
    Threads.@threads for i = 1:cpu.n
            val_3 = tmp_lvl_val
            tmp_lvl_val = moveto(tmp_lvl_val, CPUThread(i, cpu, Serial()))
            phase_start_2 = max(1, 1 + fld(y_stop * (i + -1), cpu.n))
            phase_stop_2 = min(y_stop, fld(y_stop * i, cpu.n))
            if phase_stop_2 >= phase_start_2
                for y_8 = phase_start_2:phase_stop_2
                    input_lvl_q_2 = (1 - 1) * input_lvl.shape + (y_8 + 0)
                    input_lvl_q = (1 - 1) * input_lvl.shape + y_8
                    input_lvl_q_3 = (1 - 1) * input_lvl.shape + (y_8 + 0)
                    output_lvl_q = (1 - 1) * (input_lvl.shape + -0) + y_8
                    Finch.resize_if_smaller!(tmp_lvl_val, input_lvl_2.shape)
                    Finch.fill_range!(tmp_lvl_val, 0, 1, input_lvl_2.shape)
                    input_lvl_2_q = input_lvl_ptr[input_lvl_q_2]
                    input_lvl_2_q_stop = input_lvl_ptr[input_lvl_q_2 + 1]
                    if input_lvl_2_q < input_lvl_2_q_stop
                        input_lvl_2_i1 = input_lvl_idx[input_lvl_2_q_stop - 1]
                    else
                        input_lvl_2_i1 = 0
                    end
                    input_lvl_2_q_2 = input_lvl_ptr[input_lvl_q]
                    input_lvl_2_q_stop_2 = input_lvl_ptr[input_lvl_q + 1]
                    if input_lvl_2_q_2 < input_lvl_2_q_stop_2
                        input_lvl_2_i1_2 = input_lvl_idx[input_lvl_2_q_stop_2 - 1]
                    else
                        input_lvl_2_i1_2 = 0
                    end
                    input_lvl_2_q_3 = input_lvl_ptr[input_lvl_q_3]
                    input_lvl_2_q_stop_3 = input_lvl_ptr[input_lvl_q_3 + 1]
                    if input_lvl_2_q_3 < input_lvl_2_q_stop_3
                        input_lvl_2_i1_3 = input_lvl_idx[input_lvl_2_q_stop_3 - 1]
                    else
                        input_lvl_2_i1_3 = 0
                    end
                    phase_stop_3 = min(input_lvl_2.shape, input_lvl_2_i1_2, -1 + input_lvl_2_i1_3, 1 + input_lvl_2_i1)
                    if phase_stop_3 >= 1
                        x = 1
                        if input_lvl_idx[input_lvl_2_q] < 1 + -1
                            input_lvl_2_q = Finch.scansearch(input_lvl_idx, 1 + -1, input_lvl_2_q, input_lvl_2_q_stop - 1)
                        end
                        if input_lvl_idx[input_lvl_2_q_2] < 1
                            input_lvl_2_q_2 = Finch.scansearch(input_lvl_idx, 1, input_lvl_2_q_2, input_lvl_2_q_stop_2 - 1)
                        end
                        if input_lvl_idx[input_lvl_2_q_3] < 1 + 1
                            input_lvl_2_q_3 = Finch.scansearch(input_lvl_idx, 1 + 1, input_lvl_2_q_3, input_lvl_2_q_stop_3 - 1)
                        end
                        while x <= phase_stop_3
                            input_lvl_2_i = input_lvl_idx[input_lvl_2_q]
                            input_lvl_2_i_2 = input_lvl_idx[input_lvl_2_q_2]
                            input_lvl_2_i_3 = input_lvl_idx[input_lvl_2_q_3]
                            phase_stop_4 = min(phase_stop_3, input_lvl_2_i_2, -1 + input_lvl_2_i_3, 1 + input_lvl_2_i)
                            if (input_lvl_2_i == phase_stop_4 + -1 && input_lvl_2_i_2 == phase_stop_4) && input_lvl_2_i_3 == phase_stop_4 + 1
                                input_lvl_3_val_2 = input_lvl_2_val[input_lvl_2_q_2]
                                input_lvl_3_val = input_lvl_2_val[input_lvl_2_q]
                                input_lvl_3_val_3 = input_lvl_2_val[input_lvl_2_q_3]
                                tmp_lvl_q = (1 - 1) * input_lvl_2.shape + phase_stop_4
                                tmp_lvl_val[tmp_lvl_q] = input_lvl_3_val_2 + tmp_lvl_val[tmp_lvl_q] + input_lvl_3_val + input_lvl_3_val_3
                                input_lvl_2_q += 1
                                input_lvl_2_q_2 += 1
                                input_lvl_2_q_3 += 1
                            elseif input_lvl_2_i_2 == phase_stop_4 && input_lvl_2_i_3 == phase_stop_4 + 1
                                input_lvl_3_val_2 = input_lvl_2_val[input_lvl_2_q_2]
                                input_lvl_3_val_3 = input_lvl_2_val[input_lvl_2_q_3]
                                tmp_lvl_q = (1 - 1) * input_lvl_2.shape + phase_stop_4
                                tmp_lvl_val[tmp_lvl_q] = input_lvl_3_val_2 + tmp_lvl_val[tmp_lvl_q] + input_lvl_3_val_3
                                input_lvl_2_q_2 += 1
                                input_lvl_2_q_3 += 1
                            elseif input_lvl_2_i == phase_stop_4 + -1 && input_lvl_2_i_3 == phase_stop_4 + 1
                                input_lvl_3_val = input_lvl_2_val[input_lvl_2_q]
                                input_lvl_3_val_3 = input_lvl_2_val[input_lvl_2_q_3]
                                tmp_lvl_q = (1 - 1) * input_lvl_2.shape + phase_stop_4
                                tmp_lvl_val[tmp_lvl_q] = input_lvl_3_val_3 + input_lvl_3_val + tmp_lvl_val[tmp_lvl_q]
                                input_lvl_2_q += 1
                                input_lvl_2_q_3 += 1
                            elseif input_lvl_2_i_3 == phase_stop_4 + 1
                                input_lvl_3_val_3 = input_lvl_2_val[input_lvl_2_q_3]
                                tmp_lvl_q = (1 - 1) * input_lvl_2.shape + phase_stop_4
                                tmp_lvl_val[tmp_lvl_q] = input_lvl_3_val_3 + tmp_lvl_val[tmp_lvl_q]
                                input_lvl_2_q_3 += 1
                            elseif input_lvl_2_i == phase_stop_4 + -1 && input_lvl_2_i_2 == phase_stop_4
                                input_lvl_3_val_2 = input_lvl_2_val[input_lvl_2_q_2]
                                input_lvl_3_val = input_lvl_2_val[input_lvl_2_q]
                                tmp_lvl_q = (1 - 1) * input_lvl_2.shape + phase_stop_4
                                tmp_lvl_val[tmp_lvl_q] = input_lvl_3_val + input_lvl_3_val_2 + tmp_lvl_val[tmp_lvl_q]
                                input_lvl_2_q += 1
                                input_lvl_2_q_2 += 1
                            elseif input_lvl_2_i_2 == phase_stop_4
                                input_lvl_3_val_2 = input_lvl_2_val[input_lvl_2_q_2]
                                tmp_lvl_q = (1 - 1) * input_lvl_2.shape + phase_stop_4
                                tmp_lvl_val[tmp_lvl_q] = input_lvl_3_val_2 + tmp_lvl_val[tmp_lvl_q]
                                input_lvl_2_q_2 += 1
                            elseif input_lvl_2_i == phase_stop_4 + -1
                                input_lvl_3_val = input_lvl_2_val[input_lvl_2_q]
                                tmp_lvl_q = (1 - 1) * input_lvl_2.shape + phase_stop_4
                                tmp_lvl_val[tmp_lvl_q] = input_lvl_3_val + tmp_lvl_val[tmp_lvl_q]
                                input_lvl_2_q += 1
                            end
                            x = phase_stop_4 + 1
                        end
                    end
                    phase_start_5 = max(1, 2 + input_lvl_2_i1)
                    phase_stop_5 = min(input_lvl_2.shape, input_lvl_2_i1_2, -1 + input_lvl_2_i1_3)
                    if phase_stop_5 >= phase_start_5
                        x = phase_start_5
                        if input_lvl_idx[input_lvl_2_q_2] < phase_start_5
                            input_lvl_2_q_2 = Finch.scansearch(input_lvl_idx, phase_start_5, input_lvl_2_q_2, input_lvl_2_q_stop_2 - 1)
                        end
                        if input_lvl_idx[input_lvl_2_q_3] < phase_start_5 + 1
                            input_lvl_2_q_3 = Finch.scansearch(input_lvl_idx, phase_start_5 + 1, input_lvl_2_q_3, input_lvl_2_q_stop_3 - 1)
                        end
                        while x <= phase_stop_5
                            input_lvl_2_i_2 = input_lvl_idx[input_lvl_2_q_2]
                            input_lvl_2_i_3 = input_lvl_idx[input_lvl_2_q_3]
                            phase_stop_6 = min(input_lvl_2_i_2, -1 + input_lvl_2_i_3, phase_stop_5)
                            if input_lvl_2_i_2 == phase_stop_6 && input_lvl_2_i_3 == phase_stop_6 + 1
                                input_lvl_3_val_5 = input_lvl_2_val[input_lvl_2_q_3]
                                input_lvl_3_val_4 = input_lvl_2_val[input_lvl_2_q_2]
                                tmp_lvl_q = (1 - 1) * input_lvl_2.shape + phase_stop_6
                                tmp_lvl_val[tmp_lvl_q] = input_lvl_3_val_5 + tmp_lvl_val[tmp_lvl_q] + input_lvl_3_val_4
                                input_lvl_2_q_2 += 1
                                input_lvl_2_q_3 += 1
                            elseif input_lvl_2_i_3 == phase_stop_6 + 1
                                input_lvl_3_val_5 = input_lvl_2_val[input_lvl_2_q_3]
                                tmp_lvl_q = (1 - 1) * input_lvl_2.shape + phase_stop_6
                                tmp_lvl_val[tmp_lvl_q] = input_lvl_3_val_5 + tmp_lvl_val[tmp_lvl_q]
                                input_lvl_2_q_3 += 1
                            elseif input_lvl_2_i_2 == phase_stop_6
                                input_lvl_3_val_4 = input_lvl_2_val[input_lvl_2_q_2]
                                tmp_lvl_q = (1 - 1) * input_lvl_2.shape + phase_stop_6
                                tmp_lvl_val[tmp_lvl_q] = input_lvl_3_val_4 + tmp_lvl_val[tmp_lvl_q]
                                input_lvl_2_q_2 += 1
                            end
                            x = phase_stop_6 + 1
                        end
                    end
                    phase_start_7 = max(1, 1 + input_lvl_2_i1_2)
                    phase_stop_7 = min(input_lvl_2.shape, -1 + input_lvl_2_i1_3, 1 + input_lvl_2_i1)
                    if phase_stop_7 >= phase_start_7
                        x = phase_start_7
                        if input_lvl_idx[input_lvl_2_q] < phase_start_7 + -1
                            input_lvl_2_q = Finch.scansearch(input_lvl_idx, phase_start_7 + -1, input_lvl_2_q, input_lvl_2_q_stop - 1)
                        end
                        if input_lvl_idx[input_lvl_2_q_3] < phase_start_7 + 1
                            input_lvl_2_q_3 = Finch.scansearch(input_lvl_idx, phase_start_7 + 1, input_lvl_2_q_3, input_lvl_2_q_stop_3 - 1)
                        end
                        while x <= phase_stop_7
                            input_lvl_2_i = input_lvl_idx[input_lvl_2_q]
                            input_lvl_2_i_3 = input_lvl_idx[input_lvl_2_q_3]
                            phase_stop_8 = min(-1 + input_lvl_2_i_3, 1 + input_lvl_2_i, phase_stop_7)
                            if input_lvl_2_i == phase_stop_8 + -1 && input_lvl_2_i_3 == phase_stop_8 + 1
                                input_lvl_3_val_7 = input_lvl_2_val[input_lvl_2_q_3]
                                input_lvl_3_val_6 = input_lvl_2_val[input_lvl_2_q]
                                tmp_lvl_q = (1 - 1) * input_lvl_2.shape + phase_stop_8
                                tmp_lvl_val[tmp_lvl_q] = input_lvl_3_val_7 + tmp_lvl_val[tmp_lvl_q] + input_lvl_3_val_6
                                input_lvl_2_q += 1
                                input_lvl_2_q_3 += 1
                            elseif input_lvl_2_i_3 == phase_stop_8 + 1
                                input_lvl_3_val_7 = input_lvl_2_val[input_lvl_2_q_3]
                                tmp_lvl_q = (1 - 1) * input_lvl_2.shape + phase_stop_8
                                tmp_lvl_val[tmp_lvl_q] = input_lvl_3_val_7 + tmp_lvl_val[tmp_lvl_q]
                                input_lvl_2_q_3 += 1
                            elseif input_lvl_2_i == phase_stop_8 + -1
                                input_lvl_3_val_6 = input_lvl_2_val[input_lvl_2_q]
                                tmp_lvl_q = (1 - 1) * input_lvl_2.shape + phase_stop_8
                                tmp_lvl_val[tmp_lvl_q] = input_lvl_3_val_6 + tmp_lvl_val[tmp_lvl_q]
                                input_lvl_2_q += 1
                            end
                            x = phase_stop_8 + 1
                        end
                    end
                    phase_start_9 = max(1, 1 + input_lvl_2_i1_2, 2 + input_lvl_2_i1)
                    phase_stop_9 = min(input_lvl_2.shape, -1 + input_lvl_2_i1_3)
                    if phase_stop_9 >= phase_start_9
                        if input_lvl_idx[input_lvl_2_q_3] < phase_start_9 + 1
                            input_lvl_2_q_3 = Finch.scansearch(input_lvl_idx, phase_start_9 + 1, input_lvl_2_q_3, input_lvl_2_q_stop_3 - 1)
                        end
                        while true
                            input_lvl_2_i_3 = input_lvl_idx[input_lvl_2_q_3]
                            phase_stop_10 = -1 + input_lvl_2_i_3
                            if phase_stop_10 < phase_stop_9
                                input_lvl_3_val_8 = input_lvl_2_val[input_lvl_2_q_3]
                                tmp_lvl_q = (1 - 1) * input_lvl_2.shape + phase_stop_10
                                tmp_lvl_val[tmp_lvl_q] = input_lvl_3_val_8 + tmp_lvl_val[tmp_lvl_q]
                                input_lvl_2_q_3 += 1
                            else
                                phase_stop_11 = min(-1 + input_lvl_2_i_3, phase_stop_9)
                                if input_lvl_2_i_3 == phase_stop_11 + 1
                                    input_lvl_3_val_8 = input_lvl_2_val[input_lvl_2_q_3]
                                    tmp_lvl_q = (1 - 1) * input_lvl_2.shape + phase_stop_11
                                    tmp_lvl_val[tmp_lvl_q] = input_lvl_3_val_8 + tmp_lvl_val[tmp_lvl_q]
                                    input_lvl_2_q_3 += 1
                                end
                                break
                            end
                        end
                    end
                    phase_start_12 = max(1, input_lvl_2_i1_3)
                    phase_stop_12 = min(input_lvl_2.shape, input_lvl_2_i1_2, 1 + input_lvl_2_i1)
                    if phase_stop_12 >= phase_start_12
                        x = phase_start_12
                        if input_lvl_idx[input_lvl_2_q_2] < phase_start_12
                            input_lvl_2_q_2 = Finch.scansearch(input_lvl_idx, phase_start_12, input_lvl_2_q_2, input_lvl_2_q_stop_2 - 1)
                        end
                        if input_lvl_idx[input_lvl_2_q] < phase_start_12 + -1
                            input_lvl_2_q = Finch.scansearch(input_lvl_idx, phase_start_12 + -1, input_lvl_2_q, input_lvl_2_q_stop - 1)
                        end
                        while x <= phase_stop_12
                            input_lvl_2_i_2 = input_lvl_idx[input_lvl_2_q_2]
                            input_lvl_2_i = input_lvl_idx[input_lvl_2_q]
                            phase_stop_13 = min(input_lvl_2_i_2, 1 + input_lvl_2_i, phase_stop_12)
                            if input_lvl_2_i_2 == phase_stop_13 && input_lvl_2_i == phase_stop_13 + -1
                                input_lvl_3_val_9 = input_lvl_2_val[input_lvl_2_q]
                                input_lvl_3_val_10 = input_lvl_2_val[input_lvl_2_q_2]
                                tmp_lvl_q = (1 - 1) * input_lvl_2.shape + phase_stop_13
                                tmp_lvl_val[tmp_lvl_q] = input_lvl_3_val_9 + tmp_lvl_val[tmp_lvl_q] + input_lvl_3_val_10
                                input_lvl_2_q_2 += 1
                                input_lvl_2_q += 1
                            elseif input_lvl_2_i == phase_stop_13 + -1
                                input_lvl_3_val_9 = input_lvl_2_val[input_lvl_2_q]
                                tmp_lvl_q = (1 - 1) * input_lvl_2.shape + phase_stop_13
                                tmp_lvl_val[tmp_lvl_q] = input_lvl_3_val_9 + tmp_lvl_val[tmp_lvl_q]
                                input_lvl_2_q += 1
                            elseif input_lvl_2_i_2 == phase_stop_13
                                input_lvl_3_val_10 = input_lvl_2_val[input_lvl_2_q_2]
                                tmp_lvl_q = (1 - 1) * input_lvl_2.shape + phase_stop_13
                                tmp_lvl_val[tmp_lvl_q] = input_lvl_3_val_10 + tmp_lvl_val[tmp_lvl_q]
                                input_lvl_2_q_2 += 1
                            end
                            x = phase_stop_13 + 1
                        end
                    end
                    phase_start_14 = max(1, input_lvl_2_i1_3, 2 + input_lvl_2_i1)
                    phase_stop_14 = min(input_lvl_2.shape, input_lvl_2_i1_2)
                    if phase_stop_14 >= phase_start_14
                        if input_lvl_idx[input_lvl_2_q_2] < phase_start_14
                            input_lvl_2_q_2 = Finch.scansearch(input_lvl_idx, phase_start_14, input_lvl_2_q_2, input_lvl_2_q_stop_2 - 1)
                        end
                        while true
                            input_lvl_2_i_2 = input_lvl_idx[input_lvl_2_q_2]
                            if input_lvl_2_i_2 < phase_stop_14
                                input_lvl_3_val_11 = input_lvl_2_val[input_lvl_2_q_2]
                                tmp_lvl_q = (1 - 1) * input_lvl_2.shape + input_lvl_2_i_2
                                tmp_lvl_val[tmp_lvl_q] = input_lvl_3_val_11 + tmp_lvl_val[tmp_lvl_q]
                                input_lvl_2_q_2 += 1
                            else
                                phase_stop_16 = min(input_lvl_2_i_2, phase_stop_14)
                                if input_lvl_2_i_2 == phase_stop_16
                                    input_lvl_3_val_11 = input_lvl_2_val[input_lvl_2_q_2]
                                    tmp_lvl_q = (1 - 1) * input_lvl_2.shape + phase_stop_16
                                    tmp_lvl_val[tmp_lvl_q] = input_lvl_3_val_11 + tmp_lvl_val[tmp_lvl_q]
                                    input_lvl_2_q_2 += 1
                                end
                                break
                            end
                        end
                    end
                    phase_start_16 = max(1, input_lvl_2_i1_3, 1 + input_lvl_2_i1_2)
                    phase_stop_17 = min(input_lvl_2.shape, 1 + input_lvl_2_i1)
                    if phase_stop_17 >= phase_start_16
                        if input_lvl_idx[input_lvl_2_q] < phase_start_16 + -1
                            input_lvl_2_q = Finch.scansearch(input_lvl_idx, phase_start_16 + -1, input_lvl_2_q, input_lvl_2_q_stop - 1)
                        end
                        while true
                            input_lvl_2_i = input_lvl_idx[input_lvl_2_q]
                            phase_stop_18 = 1 + input_lvl_2_i
                            if phase_stop_18 < phase_stop_17
                                input_lvl_3_val_12 = input_lvl_2_val[input_lvl_2_q]
                                tmp_lvl_q = (1 - 1) * input_lvl_2.shape + phase_stop_18
                                tmp_lvl_val[tmp_lvl_q] = input_lvl_3_val_12 + tmp_lvl_val[tmp_lvl_q]
                                input_lvl_2_q += 1
                            else
                                phase_stop_19 = min(1 + input_lvl_2_i, phase_stop_17)
                                if input_lvl_2_i == phase_stop_19 + -1
                                    input_lvl_3_val_12 = input_lvl_2_val[input_lvl_2_q]
                                    tmp_lvl_q = (1 - 1) * input_lvl_2.shape + phase_stop_19
                                    tmp_lvl_val[tmp_lvl_q] = input_lvl_3_val_12 + tmp_lvl_val[tmp_lvl_q]
                                    input_lvl_2_q += 1
                                end
                                break
                            end
                        end
                    end
                    for x_46 = 1:input_lvl_2.shape
                        output_lvl_2_q = (output_lvl_q - 1) * input_lvl_2.shape + x_46
                        tmp_lvl_q_2 = (1 - 1) * input_lvl_2.shape + x_46
                        tmp_lvl_2_val = tmp_lvl_val[tmp_lvl_q_2]
                        output_lvl_2_val[output_lvl_2_q] = tmp_lvl_2_val
                    end
                end
            end
            tmp_lvl_val = val_3
        end
    qos = 1 * (input_lvl.shape + -0)
    qos_2 = qos * input_lvl_2.shape
    resize!(val_2, qos_2)
    (output = Tensor((DenseLevel){Int64}((DenseLevel){Int64}(output_lvl_3, input_lvl_2.shape), input_lvl.shape + -0)),)
end
