class Driver_Monitor #(parameter drvrs = 4, parameter pckg_sz = 16);

    virtual bus_intf #(.drvrs(drvrs), .pckg_sz(pckg_sz))    bus_intf;                 //interfaz virtual del bus 
    bus_transaction #(.pck_sz(pcg_sz), .drvr(drvr))         bus_transaction;    //transacción del agente del driver
    bus_mbx                                                 agnt_drvr_mbx;            //mailbox del agente del driver
    bus_mbx                                                 drv_chkr_mbx
    int                                                     drvr_num;                 //número del driver

    bit [pckg_sz-1:0]                                       fifo_in[$];               //fifo de entrada
    bit [pckg_sz-1:0]                                       fifo_out[$];              //fifo de salida
    //bit [pck_sz-1:0]                                      dato;                     //dato

    function new (int drvr_num);                                                    //constructor
        fifo_in = {};                                                               //se inicializa la fifo de entrada vacía
        fifo_out = {};                                                              //se inicializa la fifo de salida vacía
        this.drvr_num = drvr_num;                                                   //se asigna el número del driver   
    endfunction

    task run ()
        $display("[%g] El driver_monitor fue inicializado", $time);
        @(posedge bus_intf.clk);
        bus_intf.rst = 1;
        @(posedge bus_intf.clk);
        forever begin
            bus_transaction #(parameter pckg_sz = 16, parameter drvrs=4) transaction;
            $display("[%g] El driver espera por una transacción", $time);
            agnt_drvr_mbx.get(transaction);
            transaction.print("Driver: Transacción recibida");
            $display("Transacciones pendientes en el mbx agnt_drv = %g", agnt_drvr_mbx.num());

            case(transaction.tipo)
                enviar_dato: begin
                    //Agregar el dato a la fifo_in
                    this.fifo_in.push_back(transaction.paquete);                                           //se agrega un dato al final de la fifo de entrada
                    $display("[%g] Se ha enviando un dato= 0x%h",
                    $time, transaction.paquete);
                    //Trabajo al bus
                    this.bus_intf.D_pop[0][this.drvr_num] = fifo_in[0];                     //se actualiza el valor de D_pop con el primer dato de la fifo de entrada
                    this.bus_intf.pndng[0][this.drvr_num] = 1;                              //se actualiza el valor de pndng a 1
                end
                recibir_dato: begin
                    @(posedge this.bus_intf.push[0][this.drvr_num]);                        //se espera a que se active la señal push del bus
                    this.fifo_out.push_back(this.bus_intf.D_push[0][this.drvr_num]);        //se agrega un dato al final de la fifo de salida
                    // Aquí puedes acceder a los campos de la transacción
                    $display("[%g] El monitor recibió un dato= 0x%h desde el dispositivo ID=%0d", 
                            $time, transaction.dato, transaction.id);// preguntar

                    // Enviar la transacción al checker vía mailbox
                    drv_chkr_mbx.put(transaction);  // Enviar el paquete completo al mailbox del checker

                    @(posedge this.bus_intf.clk);                                           //se espera a que se active el flanco de subida del reloj
                    this.fifo_out.pop_front(); //this.fifo_out.delete(0);                   //se elimina el primer dato de la fifo de salida
                end
                eliminar_dato: begin                                                        
                    @(posedge this.bus_intf.pop[0][this.drvr_num]);                         //se espera a que se active la señal pop del bus
                    this.fifo_in.pop_front(); //this.fifo_in.delete(0);                     //se elimina el primer dato de la fifo de entrada
                end
            endcase
        end
    endtask
endclass
