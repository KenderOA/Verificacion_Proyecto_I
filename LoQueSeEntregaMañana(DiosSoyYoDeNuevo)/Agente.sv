class Agente #(parameter drvrs = 4, parameter pckg_sz = 16);

    bus_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz))   bus_mbx_array [drvrs]; //agnt_drvr_mbx_array   //Arreglo de mailboxes
    bus_transaction #(.drvrs(drvrs), .pckg_sz(pckg_sz))       bus_transaction; //agnt_drvr_transaction         //Transacción

    gen_agnt_mbx                                        gen_agnt_mbx;                   //Mailbox
    gen_agnt                                            gen_agnt_transaction;           //Transacción

    int num_transacciones;
    //int tmp_ret; //delay
    int fuente; //dis_src

    function new();

    this.bus_transaction = new();

        for (int i = 0; i < drvrs; i++) begin
            this.bus_mbx_array[i] = new(); // Cambio de chatgpt
        end

        //for (int i = 0; i < drvrs; i++) begin
            //temp int index = i;                                        //Variable temporal
            //this.bus_mbx_array[index] = new();                   //Inicialización de mailboxes
        //end
    endfunction
    
    task run();
      	$display("Agente inicializado");
        forever begin
            this.gen_agnt_mbx.get(this.gen_agnt_transaction);               
            this.num_transacciones = this.gen_agnt_transaction.cant_datos;
            for (int i = 0; i < this.num_transacciones; i++) begin

                case (this.gen_agnt_transaction.tipo_data)
                    //this.bus_transaction = new(); //no se si ponerlo
                    max_variabilidad: bus_transaction.dato_valido.constraint_mode(1);        //Modo de variabilidad
                    max_aleatoriedad: bus_transaction.dato_valido.constraint_mode(0);         //Modo de aleatoriedad
                    default: bus_transaction.dato_valido.constraint_mode(0);                //Modo por defecto
                endcase

                case (this.gen_agnt_transaction.tipo_id)
                    self_id: begin
                        bus_transaction.fuente_destino.constraint_mode(0);                            //Modo de auto identificación
                        bus_transaction.id_valida.constraint_mode(1);                           //Modo de dirección válida
                        bus_transaction.fuente_valida.constraint_mode(1);                          //Modo de dirección de origen
                        bus_transaction.dispositivo_valido.constraint_mode(1);                      
                    end
                    any_id: begin
                        bus_transaction.fuente_destino.constraint_mode(0);
                        bus_transaction.id_valida.constraint_mode(0);
                        bus_transaction.fuente_valida.constraint_mode(1);
                        bus_transaction.dispositivo_valido.constraint_mode(1);
                    end
                    invalid_id: begin
                        bus_transaction.fuente_destino.constraint_mode(1);
                        bus_transaction.id_valida.constraint_mode(0);
                        bus_transaction.fuente_valida.constraint_mode(1);
                        bus_transaction.dispositivo_valido.constraint_mode(1);
                    end
                    fix_source: begin
                        bus_transaction.fuente_destino.constraint_mode(1);
                        bus_transaction.id_valida.constraint_mode(1);
                        bus_transaction.fuente_valida.constraint_mode(1);
                        bus_transaction.dispositivo_valido.constraint_mode(1);
                    end
                    normal_id: begin
                        bus_transaction.fuente_destino.constraint_mode(1);
                        bus_transaction.id_valida.constraint_mode(1);
                        bus_transaction.fuente_valida.constraint_mode(1);
                        bus_transaction.dispositivo_valido.constraint_mode(1);
                    end
                    default: begin
                        bus_transaction.fuente_destino.constraint_mode(1);
                        bus_transaction.id_valida.constraint_mode(1);
                    end
                endcase

                this.bus_transaction.randomize(); //no sé si ponerlo

                if (this.gen_agnt_transaction.dis_src_rand== 0) begin
                    bus_transaction.dis_src = gen_agnt_transaction.dis_src;
                    if (bus_transaction.id == bus_transaction.dis_src) begin
                        if (bus_transaction.id == 0) bus_transaction.id = bus_transaction.id + 1;
                        else bus_transaction.id = bus_transaction.id - 1;
                    end
                end

                if (this.gen_agnt_transaction.id_rand == 0) begin
                    bus_transaction.id = gen_agnt_transaction.id;
                    if (bus_transaction.id == bus_transaction.dis_src) begin
                        if (bus_transaction.dis_src == 0) bus_transaction.dis_src = bus_transaction.id + 1;
                        else bus_transaction.dis_src = bus_transaction.dis_src - 1;
                    end
                end

                this.bus_transaction.tiempo= $time;
                this.bus_mbx_array[this.bus_transaction.dis_src].put(this.bus_transaction);
              $display("Tamaño de bus_mbx_array: %d", $size(this.bus_mbx_array));
                         $display("Dispositivo fuente: %d",this.bus_transaction.dis_src);
              $display("Transaccion: %d",this.bus_transaction);

            end
        end
    endtask
endclass
