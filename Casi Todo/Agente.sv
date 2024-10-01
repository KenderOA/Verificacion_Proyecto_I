class Agente #(parameter drvrs = 4, parameter pckg_sz = 16);

    agnt_drvr_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz))   agnt_drvr_mbx_array [drvrs];    //Arreglo de mailboxes
    agnt_drvr #(.drvrs(drvrs), .pckg_sz(pckg_sz))       agnt_drvr_transaction;          //Transacción

    gen_agnt_mbx                                        gen_agnt_mbx;                   //Mailbox
    gen_agnt                                            gen_agnt_transaction;           //Transacción

    agnt_chk_sb_mbx #(.pckg_sz(pckg_sz))                agnt_chk_sb_mbx;                //Mailbox
    agnt_chk_sb #(.pckg_sz(pckg_sz))                    agnt_chk_sb_transaction;        //Transacción

    int num_transacciones;
    int delay;
    int source;

    function new();

    this.agnt_drvr_transaction = new();

        for (int i = 0; i < drvrs; i++) begin
            temp int index = i;                                        //Variable temporal
            this.agnt_drvr_mbx_array[index] = new();                   //Inicialización de mailboxes
        end
            $dispplay("Agente inicializado");
    endfunction
    
    task run();
        forever begin
            this.gen_agnt_mbx.get(this.gen_agnt_transaction);               
            this.num_transacciones = this.gen_agnt_transaction.num_data;
            for (int i = 0; i < this.num_transacciones; i++) begin
                case (this.agnt_drvr_transaction.data_mode)
                    this.agnt_drvr_transaction = new(); //no se si ponerlo
                    max_variability: agnt_drvr_transaction.data_variablility.constraint_mode(1);        //Modo de variabilidad
                    max_randomness: agnt_drvr_transaction.data_variablility.constraint_mode(0);         //Modo de aleatoriedad
                    default: agnt_drvr_transaction.data_variablility.constraint_mode(0);                //Modo por defecto
                endcase

                case (this.gen_agnt_transaction.id_mode)
                    self_id: begin
                        agnt_drvr_transaction.self_addrs.constraint_mode(0);                            //Modo de auto identificación
                        agnt_drvr_transaction.valid_addrs.constraint_mode(1);                           //Modo de dirección válida
                        agnt_drvr_transaction.source_addrs.constraint_mode(1);                          //Modo de dirección de origen
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

                this.agnt_drvr_transaction.randomize(); //no sé si ponerlo

                if (this.gen_agnt_transaction.source_rand == 0) begin
                    agnt_drvr_transaction.source = gen_agnt_transaction.source;
                    if (agnt_drvr_transaction.id == agnt_drvr_transaction.source) begin
                        if (agnt_drvr_transaction.id == 0) agnt_drvr_transaction.id = agnt_drvr_transaction.id + 1;
                        else agnt_drvr_transaction.id = agnt_drvr_transaction.id - 1;
                    end
                end

                if (this.gen_agnt_transaction.id_rand == 0) begin
                    agnt_drvr_transaction.id = gen_agnt_transaction.id;
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