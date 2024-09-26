class agent #(parameter width = 16, parameter depth = 8);
    trans_fifo_mbx agnt_drv_mbx; // Mailbox del agente al driver
    comando_test_agent_mbx test_agent_mbx; // Mailbox del agente al driver
    int num_transacciones; // Número de transacciones para las funciones del agente
    int max_retardo;
    int ret_spec;
    tipo_trans tpo_spec;
    bit [width-1:0] dto_spec; // para guardar la última instrucción leída
    instrucciones_agente instruccion;
    trans_fifo #( .width(width)) transaccion;

    function new;
        num_transacciones = 3;
        max_retardo = 10;
    endfunction

    task run;
        $display("[%g] El Agente fue inicializado", $time);
        forever begin
        #1;
            if (test_agent_mbx.num() > 0) begin
                $display("[%g] Agente: se recibe instrucción", $time);
                test_agent_mbx.get(instruccion);
                    case (instruccion)
                        llenado_aleatorio: begin // Esta instrucción genera num_transacciones escrituras seguidas del mismo número de lecturas
                            for (int i = 0; i < num_transacciones; i++) begin
                                transaccion = new;
                                transaccion.max_retardo = max_retardo;
                                transaccion.randomize();
                                tpo_spec = escritura;
                                transaccion.tipo = tpo_spec;
                                transaccion.print("Agente: transacción escritura creada");
                                agnt_drv_mbx.put(transaccion);
                            end
                
                            for (int i = 0; i < num_transacciones; i++) begin
                                transaccion = new;
                                transaccion.randomize();
                                tpo_spec = lectura;
                                transaccion.tipo = tpo_spec;
                                transaccion.print("Agente: transacción lectura creada");
                                agnt_drv_mbx.put(transaccion);
                            end

                            for (int i = 0; i < num_transacciones; i++) begin
                                transaccion = new;
                                transaccion.max_retardo = max_retardo;
                                transaccion.randomize();
                                tpo_spec = escritura;
                                transaccion.tipo = tpo_spec;
                                transaccion.print("Agente: transacción escritura creada");
                                agnt_drv_mbx.put(transaccion);
                            end

                            for (int i = 0; i < num_transacciones; i++) begin
                                transaccion = new;
                                transaccion.max_retardo = max_retardo;
                                transaccion.randomize();
                                tpo_spec = lectura_escritura;
                                transaccion.tipo = tpo_spec;
                                transaccion.print("Agente: transacción lectura_escritura creada");
                                agnt_drv_mbx.put(transaccion);
                            end
                        end
		                trans_aleatoria: begin
			                transaccion = new;
				            transaccion.max_retardo = max_retardo;
				            transaccion.randomize();
				            transaccion.print("Agente: transacción creada");
                            agnt_drv_mbx.put(transaccion);
                        end

                        trans_especifica: begin
                            transaccion = new;
                            transaccion.tipo = tpo_spec;
                            transaccion.dato = dto_spec;
                            transaccion.retardo = ret_spec;
                            transaccion.print("Agente: transacción creada");
                            agnt_drv_mbx.put(transaccion);
                        end

                        sec_trans_aleatorias: begin // Esta instrucción genera una secuencia de instrucciones aleatorias
                            for (int i = 0; i < num_transacciones; i++) begin
                                transaccion = new;
                                transaccion.max_retardo = max_retardo;
                                transaccion.randomize();
                                transaccion.print("Agente: transacción creada");
                                agnt_drv_mbx.put(transaccion);
                            end
                        end
                    endcase
            end
        end
    endtask
endclass

