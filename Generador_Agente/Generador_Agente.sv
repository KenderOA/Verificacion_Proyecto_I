class GeneradorAgente #(parameter drvrs = 4, parameter pckg_sz = 16);

    ag_dr_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz))   agnt_drvr_mbx_array [drvrs];
    ag_dr #(.drvrs(drvrs), .pckg_sz(pckg_sz))       agnt_drvr_transaction;

    ag_chk_sb_mbx #(.pckg_sz(pckg_sz))              agnt_chk_sb_mbx;
    ag_chk_sb #(.pckg_sz(pckg_sz))                  agnt_chk_sb_transaction;

    tst_agnt_mbx                                    tst_agnt_mbx;
    tst_agnt                                        tst_agnt_transaction;

    // Main attributes
    int num_transacciones;
    int delay;
    int source;

    function new();
        this.tst_agnt_transaction = new();
        this.agnt_drvr_transaction = new();
        this.agnt_chk_sb_transaction = new();

        for (int i = 0; i < drvrs; i++) begin
            temp int index = i;
            this.agnt_drvr_mbx_array[index] = new();
        end
            $display("Se ha inciado el Generador_Agente");
    endfunction

    task run();
        forever begin
            tst_agnt_mbx.get(tst_gen_transaction);
            $display("GENERADOR_AGENTE: Transaccion recivida de TEST recibida en %d", $time);
            case (this.tst_gen_transaction.caso)
                normal: begin
                    this.agnt_chk_sb_transaction.data_mode       = max_randomness; //data_mode
                    this.agnt_chk_sb_transaction.num_data        = 35;
                    this.agnt_chk_sb_transaction.id_mode         = normal_id;
                    this.agnt_chk_sb_transaction.id_rand         = 1;
                    this.agnt_chk_sb_transaction.id              = tst_agnt_transaction.id;
                    this.agnt_chk_sb_transaction.source_rand     = 1;
                    this.agnt_chk_sb_transaction.source          = tst_agnt_transaction.source;
                    agnt_chk_sb_transaction.num_data             = this.agnt_chk_sb_transaction.num_data;
                    agnt_chk_sb_mbx.put(gen_chk_sb_transaction);
                end
                broadcast: begin
                    this.agnt_chk_sb_transaction.data_mode       = max_aleatoriedad;
                    this.agnt_chk_sb_transaction.num_data        = 5;
                    this.agnt_chk_sb_transaction.id_mode         = normal_id;
                    this.agnt_chk_sb_transaction.id_rand         = 0;
                    this.agnt_chk_sb_transaction.id              = {8{1'b1}};
                    this.agnt_chk_sb_transaction.source_rand     = 1;
                    this.agnt_chk_sb_transaction.source          = tst_agnt_transaction.source;
                    agnt_chk_sb_transaction.num_data             = this.agnt_chk_sb_transaction.num_data;
                    agnt_chk_sb_mbx.put(gen_chk_sb_transaction);
                end
                one_to_all: begin
                    this.agnt_chk_sb_transaction.data_mode       = max_aleatoriedad;
                    this.agnt_chk_sb_transaction.num_data        = 40;
                    this.agnt_chk_sb_transaction.id_mode         = fix_source;
                    this.agnt_chk_sb_transaction.id_rand         = 1;
                    this.agnt_chk_sb_transaction.id              = tst_agnt_transaction.id;
                    this.agnt_chk_sb_transaction.source_rand     = 0;
                    this.agnt_chk_sb_transaction.source          = tst_agnt_transaction.source;
                    agnt_chk_sb_transaction.num_data             = this.agnt_chk_sb_transaction.num_data;
                    agnt_chk_sb_mbx.put(gen_chk_sb_transaction);
                end
                all_to_one: begin
                    this.agnt_chk_sb_transaction.data_mode       = max_aleatoriedad;
                    this.agnt_chk_sb_transaction.num_data        = 30;
                    this.agnt_chk_sb_transaction.id_mode         = fix_source;
                    this.agnt_chk_sb_transaction.id_rand         = 0;
                    this.agnt_chk_sb_transaction.id              = tst_agnt_transaction.id;
                    this.agnt_chk_sb_transaction.source_rand     = 1;
                    this.agnt_chk_sb_transaction.source          = tst_agnt_transaction.source;
                    agnt_chk_sb_transaction.num_data             = this.agnt_chk_sb_transaction.num_data;
                    agnt_chk_sb_mbx.put(gen_chk_sb_transaction);
                end
                self_id: begin
                    this.agnt_chk_sb_transaction.data_mode       = max_aleatoriedad;
                    this.agnt_chk_sb_transaction.num_data        = 5;
                    this.agnt_chk_sb_transaction.id_mode         = self_id;
                    this.agnt_chk_sb_transaction.id_rand         = 0;
                    this.agnt_chk_sb_transaction.id              = tst_agnt_transaction.id;
                    this.agnt_chk_sb_transaction.source_rand     = 0;
                    this.agnt_chk_sb_transaction.source          = tst_agnt_transaction.source;
                    agnt_chk_sb_transaction.num_data             = this.agnt_chk_sb_transaction.num_data;
                    agnt_chk_sb_mbx.put(gen_chk_sb_transaction);
                end
                any_id: begin
                    this.agnt_chk_sb_transaction.data_mode       = max_aleatoriedad;
                    this.agnt_chk_sb_transaction.num_data        = 5;
                    this.agnt_chk_sb_transaction.id_mode         = any_id;
                    this.agnt_chk_sb_transaction.id_rand         = 0;
                    this.agnt_chk_sb_transaction.id              = tst_agnt_transaction.id;
                    this.agnt_chk_sb_transaction.source_rand     = 0;
                    this.agnt_chk_sb_transaction.source          = tst_agnt_transaction.source;
                    agnt_chk_sb_transaction.num_data             = this.agnt_chk_sb_transaction.num_data;
                    agnt_chk_sb_mbx.put(gen_chk_sb_transaction);
                end
                invalid_id: begin
                    this.agnt_chk_sb_transaction.data_mode       = max_aleatoriedad;
                    this.agnt_chk_sb_transaction.num_data        = 5;
                    this.agnt_chk_sb_transaction.id_mode         = invalid_id;
                    this.agnt_chk_sb_transaction.id_rand         = 0;
                    this.agnt_chk_sb_transaction.id              = tst_agnt_transaction.id;
                    this.agnt_chk_sb_transaction.source_rand     = 0;
                    this.agnt_chk_sb_transaction.source          = tst_agnt_transaction.source;
                    agnt_chk_sb_transaction.num_data             = this.agnt_chk_sb_transaction.num_data;
                    agnt_chk_sb_mbx.put(gen_chk_sb_transaction);
                end
                default: begin
                    this.agnt_chk_sb_transaction.num_data        = 10;
                    agnt_chk_sb_mbx.put(gen_chk_sb_transaction);
                    agnt_chk_sb_transaction.num_data = this.agnt_chk_sb_transaction.num_data;
                end
            endcase

            this.num_transacciones = this.tst_agnt_transaction.num_data;

            for (int i = 0; i < this.num_transacciones; i++) begin
                this.agnt_drvr_transaction = new();
                case (this.agnt_chk_sb_transaction.data_mode)
                    max_variabilidad: ag_dr_transaction.data_variablility.constraint_mode(1);
                    max_aleatoriedad: ag_dr_transaction.data_variablility.constraint_mode(0);
                    default: ag_dr_transaction.data_variablility.constraint_mode(0);
                endcase

                case (this.gen_chk_sb_transaction.id_mode)
                    self_id: begin
                        agnt_drvr_transaction.self_addrs.constraint_mode(0);
                        agnt_drvr_transaction.valid_addrs.constraint_mode(1);
                        agnt_drvr_transaction.source_addrs.constraint_mode(1);
                        agnt_drvr_transaction.pos_source_addrs.constraint_mode(1);
                    end
                    any_id: begin
                        agnt_drvr_transaction.self_addrs.constraint_mode(0);
                        agnt_drvr_transaction.valid_addrs.constraint_mode(0);
                        agnt_drvr_transaction.source_addrs.constraint_mode(1);
                        agnt_drvr_transaction.pos_source_addrs.constraint_mode(1);
                    end
                    invalid_id: begin
                        agnt_drvr_transaction.self_addrs.constraint_mode(1);
                        agnt_drvr_transaction.valid_addrs.constraint_mode(0);
                        agnt_drvr_transaction.source_addrs.constraint_mode(1);
                        agnt_drvr_transaction.pos_source_addrs.constraint_mode(1);
                    end
                    fix_source: begin
                        agnt_drvr_transaction.self_addrs.constraint_mode(1);
                        agnt_drvr_transaction.valid_addrs.constraint_mode(1);
                        agnt_drvr_transaction.source_addrs.constraint_mode(1);
                        agnt_drvr_transaction.pos_source_addrs.constraint_mode(1);
                    end
                    normal_id: begin
                        agnt_drvr_transaction.self_addrs.constraint_mode(1);
                        agnt_drvr_transaction.valid_addrs.constraint_mode(1);
                        agnt_drvr_transaction.source_addrs.constraint_mode(1);
                        agnt_drvr_transaction.pos_source_addrs.constraint_mode(1);
                    end
                    default: begin
                        agnt_drvr_transaction.self_addrs.constraint_mode(1);
                        agnt_drvr_transaction.valid_addrs.constraint_mode(1);
                    end
                endcase

                this.agnt_drvr_transaction.randomize();

                if (this.agnt_chk_sb_transaction.source_rand == 0) begin
                    agnt_drvr_transaction.source = agmt_chk_sb_transaction.source;
                    if (agnt_drvr_transaction.id == agnt_drvr_transaction.source) begin
                        if (agnt_drvr_transaction.id == 0) agnt_drvr_transaction.id = agnt_drvr_transaction.id + 1;
                        else agnt_drvr_transaction.id = agnt_drvr_transaction.id - 1;
                    end
                end

                if (this.agnt_chk_sb_transaction.id_rand == 0) begin
                    agnt_drvr_transaction.id = gen_chk_sb_transaction.id;
                    if (agnt_drvr_transaction.id == agnt_drvr_transaction.source) begin
                        if (agnt_drvr_transaction.source == 0) agnt_drvr_transaction.source = agnt_drvr_transaction.id + 1;
                        else agnt_drvr_transaction.source = agnt_drvr_transaction.source - 1;
                    end
                end

                this.agnt_drvr_transaction.tiempo = $time;
                this.agnt_drvr_mbx_array[this.agnt_drvr_transaction.source].put(this.agnt_drvr_transaction);
            end
        end
    endtask

endclass
