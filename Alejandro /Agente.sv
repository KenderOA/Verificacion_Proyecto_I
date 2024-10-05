class Agente #(parameter drvrs = 4, parameter pckg_sz = 16);

    bus_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz))                 bus_mbx_array [drvrs]; 
    bus_transaction #(.drvrs(drvrs), .pckg_sz(pckg_sz))         bus_transaction; 

    gen_agnt_mbx                                                gen_agnt_mbx;                  
    gen_agnt                                                    gen_agnt_transaction;           

    int num_transacciones;
    int fuente; 

    function new();

    this.bus_transaction = new();

        for (int i = 0; i < drvrs; i++) begin
          automatic int k = i;
          this.bus_mbx_array[k] = new(); // Cambio de chatgpt
        end

    endfunction
    
    task run();

      	$display("[%g] ++++++++++++++ EL AGENTE FUE INICIALIZADO ++++++++++++++",$time);

        forever begin
            this.gen_agnt_mbx.get(this.gen_agnt_transaction);  
            $display("[%g] TRANSACCIÓN RECIBIDA GENERADOR => AGENTE: %h", $time, this.gen_agnt_transaction);            
            this.num_transacciones = this.gen_agnt_transaction.cant_datos;
            $display("[%g] NÚMERO DE TRANSACCIONES: %d", $time, this.num_transacciones); 

            for (int i = 0; i < this.num_transacciones; i++) begin
              
				this.bus_transaction = new();
                case (this.gen_agnt_transaction.tipo_data)
                    max_variabilidad:begin
                      bus_transaction.dato_valido.constraint_mode(1);
                    end
                    max_aleatoriedad:begin
                      bus_transaction.dato_valido.constraint_mode(0);
                    end
                    default: begin 
                      bus_transaction.dato_valido.constraint_mode(0);
                    end
                endcase

                case (this.gen_agnt_transaction.tipo_id)
                    self_id: begin
                        bus_transaction.fuente_destino.constraint_mode(0);                       
                        bus_transaction.id_valida.constraint_mode(1);                        
                        bus_transaction.fuente_valida.constraint_mode(1);                       
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

                this.bus_transaction.randomize();

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
                        if (bus_transaction.dis_src == 0)
                          bus_transaction.dis_src = bus_transaction.id + 1;
                        else bus_transaction.dis_src = bus_transaction.dis_src- 1;
                    end
                end

                this.bus_transaction.tiempo= $time;
                this.bus_mbx_array[this.bus_transaction.dis_src].put(this.bus_transaction);
                $display("[%g] TRANSACCIÓN ENVIADA AGENTE => DRIVER: %h", $time, this.bus_transaction);
              	$display("[%g] PAQUETE A ENVIAR:    %d",$time, this.bus_transaction.paquete); 
              	$display("[%g] DISPOSITIVO FUENTE:  %d",$time, this.bus_transaction.dis_src);
             	$display("[%G] DISPOSITIVO DESTINO: %d",$time, this.bus_transaction.id);
              	
            end
        end
    endtask
endclass
